// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/add_member_icon.png
  AssetGenImage get addMemberIcon =>
      const AssetGenImage('assets/icons/add_member_icon.png');

  /// File path: assets/icons/check_in_icon.png
  AssetGenImage get checkInIcon =>
      const AssetGenImage('assets/icons/check_in_icon.png');

  /// File path: assets/icons/google_icon.png
  AssetGenImage get googleIcon =>
      const AssetGenImage('assets/icons/google_icon.png');

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

  /// File path: assets/icons/spash_screen_icon.png
  AssetGenImage get spashScreenIcon =>
      const AssetGenImage('assets/icons/spash_screen_icon.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    addMemberIcon,
    checkInIcon,
    googleIcon,
    homeIcon,
    locationIcon,
    lockIcon,
    lungCareLogo,
    mainIcon,
    medsIcon,
    messageIcon,
    profileIcon,
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
