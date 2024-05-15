import 'dart:io';
import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import '../../wechat_assets_picker.dart';

class DLAssetPickerClipView extends StatefulWidget {
  const DLAssetPickerClipView({
    super.key,
    required this.assetEntity,
    this.roundCropLayerPainter,
  });

  final AssetEntity assetEntity;

  final bool? roundCropLayerPainter;

  @override
  State<DLAssetPickerClipView> createState() => _DLAssetPickerClipViewState();
}

class _DLAssetPickerClipViewState extends State<DLAssetPickerClipView> {
  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();
  File? _originAssetFile;
  bool _imageClipLoading = false;

  @override
  void initState() {
    _initFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _renderClipWidget(),
          _renderBtnWidget(),
        ],
      ),
    );
  }

  /// 图片裁剪
  Widget _renderClipWidget() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        child: _originAssetFile != null
            ? ExtendedImage(
                mode: ExtendedImageMode.editor,
                extendedImageEditorKey: _editorKey,
                image: ExtendedFileImageProvider(
                  _originAssetFile!,
                  cacheRawData: true,
                ),
                fit: BoxFit.contain,
                initEditorConfigHandler: (ExtendedImageState? state) {
                  return EditorConfig(
                    maxScale: 10,
                    cornerColor: Colors.white,
                    cornerSize: Size.zero,
                    lineColor: Colors.white,
                    lineHeight: 1,
                    cropLayerPainter: widget.roundCropLayerPainter == true
                        ? const DLEditorCropLayerPainter()
                        : const EditorCropLayerPainter(),
                    cropRectPadding:
                        EdgeInsets.symmetric(horizontal: _setWidth(16)),
                    cropAspectRatio: 1,
                    initialCropAspectRatio: CropAspectRatios.ratio1_1,
                    initCropRectType: InitCropRectType.layoutRect,
                    hitTestBehavior: HitTestBehavior.translucent,
                    hitTestSize: 0,
                    editorMaskColorHandler:
                        (BuildContext context, bool pointerDown) {
                      return Colors.black.withOpacity(0.64);
                    },
                  );
                },
              )
            : Container(),
      ),
    );
  }

  /// 确定和取消按钮
  Widget _renderBtnWidget() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: _setHeight(56),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              /// 裁剪图片
              if (!_imageClipLoading) {
                _handleClipImageLogic();
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: _setHeight(48),
              width: _setWidth(104),
              decoration: BoxDecoration(
                color: const Color(0xFF725BFF),
                borderRadius: BorderRadius.all(Radius.circular(_setHeight(24))),
              ),
              child: const Text(
                '确定',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).maybePop({'back': false});
            },
            child: Container(
              margin: EdgeInsets.only(top: _setHeight(16)),
              alignment: Alignment.center,
              height: _setHeight(48),
              width: _setWidth(104),
              decoration: BoxDecoration(
                color: const Color(0x29FFFFFF),
                borderRadius: BorderRadius.all(Radius.circular(_setHeight(24))),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initFile() async {
    final File? originFile = await widget.assetEntity.originFile;
    if (originFile != null) {
      setState(() {
        _originAssetFile = originFile;
      });
    }
  }

  Future<void> _handleClipImageLogic() async {
    setState(() {
      _imageClipLoading = true;
    });
    try {
      if (_editorKey.currentState != null) {
        final ExtendedImageEditorState state = _editorKey.currentState!;
        final Rect cropRect = state.getCropRect()!;
        final EditActionDetails action = state.editAction!;

        final int rotateAngle = action.rotateAngle.toInt();
        final bool flipHorizontal = action.flipY;
        final bool flipVertical = action.flipX;
        final Uint8List img = state.rawImageData;

        final ImageEditorOption option = ImageEditorOption();

        if (action.needCrop) {
          option.addOption(ClipOption.fromRect(cropRect));
        }

        if (action.needFlip) {
          option.addOption(
            FlipOption(
              horizontal: flipHorizontal,
              vertical: flipVertical,
            ),
          );
        }

        if (action.hasRotateAngle) {
          option.addOption(RotateOption(rotateAngle));
        }

        final DateTime start = DateTime.now();
        final Uint8List? result = await ImageEditor.editImage(
          image: img,
          imageEditorOption: option,
        );
        setState(() {
          _imageClipLoading = false;
        });
        if (result != null) {
          Navigator.of(context).maybePop({
            'back': true,
            'image': result,
          });
        }
      }
    } catch (error) {
      print('@@@@@@ clip image error: $error');
    }
  }

  double _setWidth(int width) {
    return (width / 375) * MediaQuery.of(context).size.width;
  }

  double _setHeight(int height) {
    return (height / 812) * MediaQuery.of(context).size.height;
  }
}

class DLEditorCropLayerPainter extends EditorCropLayerPainter {
  const DLEditorCropLayerPainter();

  @override
  void paintCorners(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
  ) {
    final Rect cropRect = painter.cropRect;
    final Offset center = Offset(
      cropRect.left + cropRect.width / 2,
      cropRect.top + cropRect.height / 2,
    );
    final double radius = cropRect.width / 2;

    final Paint paint = Paint()
      ..color = painter.cornerColor
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = painter.lineHeight;
    canvas.drawCircle(center, radius, paint);
    // super.paintCorners(canvas, size, painter);
  }

  @override
  void paintMask(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
  ) {
    final Rect rect = Offset.zero & size;
    final Rect cropRect = painter.cropRect;
    final Color maskColor = painter.maskColor;

    final Paint paint = Paint()
      ..color = maskColor
      ..style = PaintingStyle.fill
      ..filterQuality = FilterQuality.high;

    final Offset center = Offset(
      cropRect.left + cropRect.width / 2,
      cropRect.top + cropRect.height / 2,
    );
    final double radius = cropRect.width / 2;

    /// 绘制圆形外的区域
    final Path path = Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..fillType = PathFillType.evenOdd
      ..addRect(
        Rect.fromLTWH(rect.left, rect.top, size.width, size.height),
      );

    canvas.drawPath(path, paint);
    // super.paintMask(canvas, size, painter);
  }

  @override
  void paintLines(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {}
}
