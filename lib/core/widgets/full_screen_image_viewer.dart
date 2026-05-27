import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FullScreenImageViewer extends StatefulWidget {
  const FullScreenImageViewer({super.key});

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  final TransformationController _transformationController =
      TransformationController();

  double _dragOffset = 0;

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      _transformationController.value = Matrix4.identity()..scale(2.0);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No image data provided',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final String imageUrl = args['url'];
    final String heroTag = args['tag'] ?? imageUrl;
    final bool isAsset = args['isAsset'] ?? false;
    return GestureDetector(
      onScaleUpdate: (details) {
        if (_transformationController.value.getMaxScaleOnAxis() <= 1.0) {
          setState(() {
            _dragOffset += details.focalPointDelta.dy;
          });
        }
      },
      onScaleEnd: (details) {
        if (_dragOffset.abs() > 150) {
          Navigator.pop(context);
        } else {
          setState(() {
            _dragOffset = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black.withValues(
          alpha: (.95 - (_dragOffset.abs() / 500)).clamp(0.0, 1.0),
        ),
        body: SafeArea(
          child: Column(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _dragOffset == 0 ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      // if (!isAsset)
                      //   _isSaving
                      //       ? const Padding(
                      //         padding: EdgeInsets.all(12.0),
                      //         child: SizedBox(
                      //           width: 24,
                      //           height: 24,
                      //           child: CustomLoadingIndicator(
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       )
                      //       : PopupMenuButton<String>(
                      //         color: Colors.white,
                      //         icon: const Icon(
                      //           Icons.more_vert,
                      //           color: Colors.white,
                      //           size: 28,
                      //         ),
                      //         offset: const Offset(-24, kToolbarHeight - 12),
                      //         onSelected: (value) async {
                      //           if (value == 'save') {
                      //             setState(() => _isSaving = true);

                      //             await GalleryServices.saveMediaToGallery(
                      //               context: context,
                      //               url: imageUrl,
                      //               isVideo: false,
                      //             );

                      //             if (mounted) {
                      //               setState(() => _isSaving = false);
                      //             }
                      //           }
                      //         },
                      //         itemBuilder:
                      //             (_) => [
                      //               const PopupMenuItem(
                      //                 value: 'save',
                      //                 child: Row(
                      //                   children: [
                      //                     Icon(
                      //                       Icons.download,
                      //                       size: 18,
                      //                       color: Colors.black45,
                      //                     ),
                      //                     SizedBox(width: 8),
                      //                     Text(
                      //                       'Save to gallery',
                      //                       style: TextStyle(
                      //                         color: Colors.black45,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ],
                      //       ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, _dragOffset),
                    child: GestureDetector(
                      onDoubleTap: _handleDoubleTap,
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        clipBehavior: Clip.none,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Hero(
                          tag: heroTag,
                          child: isAsset
                              ? Image.asset(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
