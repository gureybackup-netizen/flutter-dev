import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/call_record.dart';

class CallService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;
  
  String? _currentCallId;
  String? _currentUserId;
  bool _isInitiator = false;

  final _callStateController = StreamController<VardCall>.broadcast();
  Stream<VardCall> get callStateStream => _callStateController.stream;

  Function(String conversationId, String callId)? onCallAnswered;
  Function()? onCallEnded;

  Future<void> initializeRenderers() async {
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();
    await _remoteRenderer!.initialize();
  }

  Future<void> disposeRenderers() async {
    await _localRenderer?.dispose();
    await _remoteRenderer?.dispose();
    _localRenderer = null;
    _remoteRenderer = null;
  }

  Map<String, dynamic> get _iceServers => {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  Future<RTCPeerConnection> _createPeerConnection() async {
    final pc = await createPeerConnection(_iceServers);

    pc.onIceCandidate = (candidate) {
      _sendIceCandidate(candidate);
    };

    pc.onIceConnectionState = (state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        _updateCallStatus('active');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
                 state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        endCall();
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer?.srcObject = event.streams[0];
      }
    };

    return pc;
  }

  Future<void> _sendIceCandidate(RTCIceCandidate candidate) async {
    if (_currentCallId == null) return;

    final table = _isInitiator ? 'caller_candidates' : 'callee_candidates';
    
    await _supabase.from(table).insert({
      'call_id': _currentCallId,
      'candidate': candidate.candidate,
      'sdp_mid': candidate.sdpMid,
      'sdp_m_line_index': candidate.sdpMLineIndex,
    });
  }

  Future<String> startCall({
    required String callerId,
    required String callerUsername,
    required String calleeUid,
    required String type,
  }) async {
    _currentUserId = callerId;
    _isInitiator = true;
    
    final callId = const Uuid().v4();
    _currentCallId = callId;

    await _supabase.from('calls').insert({
      'id': callId,
      'caller_id': callerId,
      'caller_username': callerUsername,
      'callee_uid': calleeUid,
      'status': 'ringing',
      'type': type,
      'created_at': DateTime.now().toIso8601String(),
    });

    _peerConnection = await _createPeerConnection();

    _localStream = await _getLocalStream(type == 'video');
    await _peerConnection!.addStream(_localStream!);

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await _supabase.from('calls').update({
      'sdp_offer': offer.sdp,
    }).eq('id', callId);

    return callId;
  }

  Future<MediaStream> _getLocalStream(bool videoEnabled) async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      if (videoEnabled) 'video': true,
    });
    _localRenderer?.srcObject = stream;
    return stream;
  }

  Future<void> answerCall(String callId, bool videoEnabled) async {
    _currentCallId = callId;
    _isInitiator = false;

    final callData = await _supabase.from('calls').select().eq('id', callId).maybeSingle();
    if (callData == null) return;

    _currentUserId = callData['callee_uid'];
    _peerConnection = await _createPeerConnection();

    _localStream = await _getLocalStream(videoEnabled);
    await _peerConnection!.addStream(_localStream!);

    final offer = callData['sdp_offer'] as String?;
    if (offer != null) {
      await _peerConnection!.setRemoteDescription(RTCSessionDescription(offer, 'offer'));
    }

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await _supabase.from('calls').update({
      'status': 'active',
      'started_at': DateTime.now().toIso8601String(),
      'sdp_answer': answer.sdp,
    }).eq('id', callId);

    onCallAnswered?.call('', callId);
  }

  Future<void> endCall() async {
    if (_currentCallId == null) return;

    _localStream?.getTracks().forEach((track) => track.stop());
    await _peerConnection?.close();
    await disposeRenderers();

    await _supabase.from('calls').update({
      'status': 'ended',
      'ended_at': DateTime.now().toIso8601String(),
    }).eq('id', _currentCallId);

    _currentCallId = null;
    _peerConnection = null;
    _localStream = null;
    onCallEnded?.call();
  }

  Future<void> _updateCallStatus(String status) async {
    if (_currentCallId == null) return;
    
    final update = <String, dynamic>{'status': status};
    if (status == 'active') {
      update['started_at'] = DateTime.now().toIso8601String();
    }
    
    await _supabase.from('calls').update(update).eq('id', _currentCallId);
  }

  RTCVideoRenderer? get localRenderer => _localRenderer;
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer;

  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.dispose();
    disposeRenderers();
    _callStateController.close();
  }
}