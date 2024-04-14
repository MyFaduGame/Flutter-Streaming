import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_streaming/live_stream_page.dart';
import 'package:flutter_streaming/models/mux_model.dart';
import 'package:flutter_streaming/playback_page.dart';
import 'package:flutter_streaming/provider/mux_provider.dart';
import 'package:flutter_streaming/strings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late MuxProvider provider;

  List<MuxLiveData>? streams;
  bool isLoading = false;

  getStreams() async {
    setState(() {
      isLoading = true;
    });

    provider = Provider.of<MuxProvider>(context, listen: false);
    provider.getListStreams().then((value) {
      setState(() {
        isLoading = false;
      });
    });

  }

  @override
  void initState() {
    getStreams();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    streams = context.select((MuxProvider value) => value.liveStreams);
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.pink,
        title: const Text(
          'MUX Live Stream',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LiveStreamPage(),
            ),
          );
        },
        child: const FaIcon(FontAwesomeIcons.video),
      ),
      body: RefreshIndicator(
        onRefresh: () => getStreams(),
        child: !isLoading && streams != null
            ? streams!.isEmpty
                ? const Center(
                    child: Text('Empty'),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: streams!.length,
                    itemBuilder: (context, index) {
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(streams![index].createdAt) * 1000,
                      );
                      DateFormat formatter =
                          DateFormat.yMMMMd().addPattern('|').add_jm();
                      String dateTimeString = formatter.format(dateTime);

                      String currentStatus = streams![index].status;
                      bool isReady = currentStatus == 'active';

                      String? playbackId =
                          isReady ? streams![index].playbackIds[0].id : null;

                      String? thumbnailURL = isReady
                          ? '$muxImageBaseUrl/$playbackId/$imageTypeSize'
                          : null;

                      return VideoTile(
                        streamData: streams![index],
                        thumbnailUrl: thumbnailURL,
                        isReady: isReady,
                        dateTimeString: dateTimeString,
                        onTap: (id) async {
                          // await MuxClient.deleteLiveStream(liveStreamId: id);
                          getStreams();
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(
                      height: 16.0,
                    ),
                  )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}


class VideoTile extends StatefulWidget {
  final MuxLiveData streamData;
  final String? thumbnailUrl;
  final String dateTimeString;
  final bool isReady;
  final Function(String id) onTap;

  const VideoTile({
    super.key,
    required this.streamData,
    required this.thumbnailUrl,
    required this.dateTimeString,
    required this.isReady,
    required this.onTap,
  });

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  bool _isLongPressed = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
          ),
          child: Container(
            decoration: _isLongPressed
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red,
                      width: 4,
                    ),
                  )
                : null,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
              child: InkWell(
                onTap: () {
                  widget.isReady
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PlaybackPage(
                              streamData: widget.streamData,
                            ),
                          ),
                        )
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('The video is not active'),
                          ),
                        );
                },
                onLongPress: () {
                  setState(() {
                    _isLongPressed = true;
                  });
                },
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.maxFinite,
                        color: Colors.pink.shade300,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          child: Text(
                            widget.streamData.id,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.isReady && widget.thumbnailUrl != null
                              ? SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: Image.network(
                                    widget.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                )
                              : Container(
                                  width: 150,
                                  height: 100,
                                  color: Colors.black26,
                                  child: const Center(
                                    child: Text(
                                      'MUX',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                      ),
                                    ),
                                  ),
                                ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                top: 8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    text: TextSpan(
                                      text: 'Status: ',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.0,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: widget.streamData.status,
                                          style: TextStyle(
                                            // fontSize: 12.0,
                                            color:
                                                Colors.black.withOpacity(0.4),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  RichText(
                                    maxLines: 2,
                                    overflow: TextOverflow.clip,
                                    text: TextSpan(
                                      text: 'Created on: ',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.0,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '\n${widget.dateTimeString}',
                                          style: TextStyle(
                                            // fontSize: 12.0,
                                            color:
                                                Colors.black.withOpacity(0.4),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _isLongPressed
            ? InkWell(
                onTap: () => widget.onTap(widget.streamData.id),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
