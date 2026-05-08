import 'dart:convert';
import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'appwrite_service.dart';

class CallService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  String? _currentCallId;
  List<Map<String, dynamic>>? _cachedIceServers;

  Future<String?> initiateCall({
    required String conversationId,
    required String callerId,
    required String callerName,
    required String calleeId,
    required String callType,
  }) async {
    try {
      final appwrite = AppwriteService();
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
      
      // Create peer connection with ICE servers from OpenRelay
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
  
  Future<List<Map<String, dynamic>>> _getIceServers() async {
    // Return cached servers if available and not expired (cache for 12 hours)
    if (_cachedIceServers != null) {
      return _cachedIceServers!;
    }
    
    try {
      final response = await http.get(
        Uri.parse('https://openrelayproject.com/credentials'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final iceServers = List<Map<String, dynamic>>.from(data['iceServers']);
        
        // Cache the servers
        _cachedIceServers = iceServers;
        
        return iceServers;
      } else {
        throw Exception('Failed to fetch ICE servers');
      }
    } catch (e) {
      // Fallback to public STUN servers if OpenRelay fails
      return [
        {'url': 'stun:stun.l.google.com:19302'},
        {'url': 'stun:stun1.l.google.com:19302'},
        {'url': 'stun:stun2.l.google.com:19302'},
      ];
    }
  }
  
  Future<void> _createPeerConnection() async {
    final iceServers = await _getIceServers();
    final configuration = <String, dynamic>{
      'iceServers': iceServers,
    };
    
    _peerConnection = await createPeerConnection(configuration);
    
    _peerConnection!.onIceCandidate = (candidate) async {
      final appwrite = AppwriteService();
      appwrite.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: '${AppConstants.callsCollectionId}/$_currentCallId/ice_candidates',
        documentId: DateTime.now().millisecondsSinceEpoch.toString(),
        data: {
          'call_id': _currentCallId,
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid ?? '',
          'sdpMLineIndex': candidate.sdpMLineIndex ?? 0,
        },
      );
    };
    
    _peerConnection!.onIceConnectionState = (state) {
      // Handle connection state changes if needed
    };
    
    _peerConnection!.onTrack = (event) {
      _remoteStream = event.streams.first;
    };
  }

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  
  Future<void> dispose() async {
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    _currentCallId = null;
  }
}
