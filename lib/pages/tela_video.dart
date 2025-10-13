import 'package:fluffychat/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/live_card.dart';
import 'package:fluffychat/widgets/streams_widget.dart';
import 'package:matrix/matrix.dart';

class TelaVideo extends StatelessWidget {
  final LiveShow live;

  const TelaVideo({
    required this.live,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Coluna da esquerda (maior)
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                children: [VideoPlayer(live: live)],
              ),
            ),
          ),

          // // Coluna da direita (menor)
          // Expanded(
          //   flex: 1,
          //   child: Padding(
          //     padding: EdgeInsets.all(8.0),
          //     child: SingleChildScrollView(
          //       physics: BouncingScrollPhysics(),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           StreamsWidget(
          //             numColumns: 1,
          //             initialVisibleCount: 3,
          //             loadMoreCount: 3,
          //             showHeader: false,
          //             streamsWidgetTag: '🔥 Destaques', // pega os VODs recentes
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
