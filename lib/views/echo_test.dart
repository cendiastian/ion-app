import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

class EchoTest extends StatefulWidget {
  @override
  _EchoTestState createState() => _EchoTestState();
}

class _EchoTestState extends State<EchoTest> {
  var localRenderer = RTCVideoRenderer();
  var remoteRenderer = RTCVideoRenderer();
  final _uuid = Uuid().v4();
  late ion.Client client;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    // Connect to ion-sfu.
    final signal = ion.JsonRPCSignal("wss://devvcall.sentuhdigital.id/server/ws");

    client = await ion.Client.create(sid: "var-session-11", uid: _uuid, signal: signal);

    client.ontrack = (track, ion.RemoteStream stream) {
      /// mute a remote stream
      // stream.mute!();
      /// unmute a remote stream
      // stream.unmute();

      if (track.kind == "video") {
        /// prefer a layer
        // stream.preferLayer(ion.Layer.medium);

        /// render remote stream.
        /// remoteRenderer.srcObject = stream.stream;
      }
    };
    print("test");
    ion.LocalStream localStream = await ion.LocalStream.getUserMedia(
      constraints: ion.Constraints.defaults..simulcast = true,
    );

    /// render local stream.
    await localRenderer.initialize();

    localRenderer.srcObject = localStream.stream;

    /// publish stream
    await client.publish(localStream);

    /// mute local stream
    // localStream.mute("audio");

    /// unmute local stream
    // localStream.unmute();

    setState(() {});
  }

  @override
  Widget build(context) => MaterialApp(
        title: 'ion-sfu',
        home: Scaffold(
            appBar: AppBar(title: Text('Echo Test')),
            body: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    'Local ${localRenderer.videoWidth}x${localRenderer.videoHeight}'),
                Expanded(child: RTCVideoView(localRenderer)),
                SizedBox(
                  height: 80,
                ),
                Text(
                    'Remote ${remoteRenderer.videoWidth}x${remoteRenderer.videoHeight}'),
                Expanded(child: RTCVideoView(remoteRenderer)),
                SizedBox(
                  height: 10,
                ),
              ],
            )),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.phone),
            )
        ),
      );

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    client.close();
    super.dispose();
  }
}
