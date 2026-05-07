// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/add_member_icon.png
  AssetGenImage get addMemberIcon =>
      const AssetGenImage('assets/icons/add_member_icon.png');

  /// File path: assets/icons/arrow_left_icon.png
  AssetGenImage get arrowLeftIcon =>
      const AssetGenImage('assets/icons/arrow_left_icon.png');

  /// File path: assets/icons/check_in_icon.png
  AssetGenImage get checkInIcon =>
      const AssetGenImage('assets/icons/check_in_icon.png');

  /// File path: assets/icons/check_rounded_icon.png
  AssetGenImage get checkRoundedIconPng =>
      const AssetGenImage('assets/icons/check_rounded_icon.png');

  /// File path: assets/icons/check_rounded_icon.svg
  SvgGenImage get checkRoundedIconSvg =>
      const SvgGenImage('assets/icons/check_rounded_icon.svg');

  /// File path: assets/icons/forgot_password_icon.png
  AssetGenImage get forgotPasswordIcon =>
      const AssetGenImage('assets/icons/forgot_password_icon.png');

  /// File path: assets/icons/google_icon.png
  AssetGenImage get googleIcon =>
      const AssetGenImage('assets/icons/google_icon.png');

  /// File path: assets/icons/hamburger_icon.png
  AssetGenImage get hamburgerIcon =>
      const AssetGenImage('assets/icons/hamburger_icon.png');

  /// File path: assets/icons/hide_eye_icon.png
  AssetGenImage get hideEyeIcon =>
      const AssetGenImage('assets/icons/hide_eye_icon.png');

  /// File path: assets/icons/home_icon.png
  AssetGenImage get homeIcon =>
      const AssetGenImage('assets/icons/home_icon.png');

  /// File path: assets/icons/location_icon.png
  AssetGenImage get locationIcon =>
      const AssetGenImage('assets/icons/location_icon.png');

  /// File path: assets/icons/lock_icon.png
  AssetGenImage get lockIcon =>
      const AssetGenImage('assets/icons/lock_icon.png');

  /// File path: assets/icons/lung_care_logo.png
  AssetGenImage get lungCareLogo =>
      const AssetGenImage('assets/icons/lung_care_logo.png');

  /// File path: assets/icons/main_icon.png
  AssetGenImage get mainIcon =>
      const AssetGenImage('assets/icons/main_icon.png');

  /// File path: assets/icons/meds_icon.png
  AssetGenImage get medsIcon =>
      const AssetGenImage('assets/icons/meds_icon.png');

  /// File path: assets/icons/message_icon.png
  AssetGenImage get messageIcon =>
      const AssetGenImage('assets/icons/message_icon.png');

  /// File path: assets/icons/profile_icon.png
  AssetGenImage get profileIcon =>
      const AssetGenImage('assets/icons/profile_icon.png');

  /// File path: assets/icons/profile_motivation.svg
  SvgGenImage get profileMotivation =>
      const SvgGenImage('assets/icons/profile_motivation.svg');

  /// File path: assets/icons/profile_motivation_img.png
  AssetGenImage get profileMotivationImg =>
      const AssetGenImage('assets/icons/profile_motivation_img.png');

  /// File path: assets/icons/spash_screen_icon.png
  AssetGenImage get spashScreenIcon =>
      const AssetGenImage('assets/icons/spash_screen_icon.png');

  /// List of all assets
  List<dynamic> get values => [
    addMemberIcon,
    arrowLeftIcon,
    checkInIcon,
    checkRoundedIconPng,
    checkRoundedIconSvg,
    forgotPasswordIcon,
    googleIcon,
    hamburgerIcon,
    hideEyeIcon,
    homeIcon,
    locationIcon,
    lockIcon,
    lungCareLogo,
    mainIcon,
    medsIcon,
    messageIcon,
    profileIcon,
    profileMotivation,
    profileMotivationImg,
    spashScreenIcon,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
