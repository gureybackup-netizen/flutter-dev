import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../core/constants.dart';
import 'appwrite_service.dart';

final callServiceProvider = Provider((ref) => CallService(ref));

class CallService {
  final Ref _ref;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  String? _currentCallId;
  StreamSubscription? _offerSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _callerCandidatesSubscription;
  StreamSubscription? _calleeCandidatesSubscription;
  
  CallService(this._ref);

  Future<String?> initiateCall({
    required String conversationId,
    required String callerId,
    required String callerName,
    required String calleeId,
    required String callType,
  }) async {
    try {
      final appwrite = _ref.read(appwriteServiceProvider);
      final callId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentCallId = callId;
      
      // Create call document
      await appwrite.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.callsCollectionId,
        documentId: callId,
        data: {
          'id': callId,
          'caller_id': callerId,
          'callee_id': calleeId,
          'caller_name': callerName,
          'type': callType,
          'status': 'ringing',
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      
      // Create peer connection
      await _createPeerConnection();
      
      // Add local stream
      final mediaConstraints = <String, dynamic>{
        'audio': true,
        'video': callType == 'video',
      };
      
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
      
      // Create offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      
      // Save offer to Appwrite
      await appwrite.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.callsCollectionId,
        documentId: '$callId-offer',
        data: {
          'call_id': callId,
          'sdp': offer.sdp,
          'type': offer.type,
        },
      );
      
      return callId;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ],
    };
    
    _peerConnection = await createPeerConnection(configuration);
    
    _peerConnection!.onIceCandidate = (candidate) {
      final appwrite = _ref.read(appwriteServiceProvider);
      appwrite.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.callsCollectionId,
        documentId: '${_currentCallId}_${DateTime.now().millisecondsSinceEpoch}',
        data: {
          'call_id': _currentCallId,
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid ?? '',
          'sdpMLineIndex': candidate.sdpMLineIndex ?? 0,
        },
      );
    };
    
    _peerConnection!.onTrack = (event) {
      _remoteStream = event.streams.first;
    };
  }
  
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  
  Future<void> dispose() async {
    await _offerSubscription?.cancel();
    await _answerSubscription?.cancel();
    await _callerCandidatesSubscription?.cancel();
    await _calleeCandidatesSubscription?.cancel();
    
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    _currentCallId = null;
  }
}
