import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_config.dart';

abstract class FluffyThemes {
  static const double columnWidth = 380.0;

  static const double maxTimelineWidth = columnWidth * 2;

  static const double navRailWidth = 80.0;

  static bool isColumnModeByWidth(double width) =>
      width > columnWidth * 2 + navRailWidth;

  static bool isColumnMode(BuildContext context) =>
      isColumnModeByWidth(MediaQuery.of(context).size.width);

  static bool isThreeColumnMode(BuildContext context) =>
      MediaQuery.of(context).size.width > FluffyThemes.columnWidth * 3.5;

  static LinearGradient backgroundGradient(
    BuildContext context,
    int alpha,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topCenter,
      colors: [
        colorScheme.primaryContainer.withAlpha(alpha),
        colorScheme.secondaryContainer.withAlpha(alpha),
        colorScheme.tertiaryContainer.withAlpha(alpha),
        colorScheme.primaryContainer.withAlpha(alpha),
      ],
    );
  }

  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Curve animationCurve = Curves.easeInOut;

  static ThemeData buildTheme(
    BuildContext context,
    Brightness brightness, [
    Color? seed,
  ]) {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF3EC2CF),
      onPrimary: Color(0xFF4F4F4F),
      primaryFixed: Color.fromARGB(0, 255, 255, 255),
      primaryContainer: Color(0xFFadadad),
      onPrimaryContainer: Color(0xFF212529),
      secondary: Color(0xFF8B89AD),
      onSecondary: Color(0xCCF7F7F7),
      secondaryContainer: Color(0xFF8B89AD),
      onSecondaryContainer: Color(0xFFADB5BD),
      tertiary: Color(0xFFF7F7F7),
      onTertiary: Color(0xFF4F4F4F),
      tertiaryContainer: Color(0xFF3D3D3D),
      onTertiaryContainer: Color(0xFF646464),
      surface: Color(0xFF4F4F4F),
      onSurface: Color(0xFF646464),
      surfaceContainerLow: Color(0xFF3EC2CF),
      surfaceContainer: Color(0xFFF7F7F7),
      surfaceContainerHighest: Color(0xFF8B89AD),
      surfaceContainerHigh: Color(0xFF4F4F4F),
      error: Color.fromARGB(255, 243, 117, 117),
      onError: Color.fromARGB(255, 243, 117, 117),
      errorContainer: Color.fromARGB(255, 243, 117, 117),
      onErrorContainer: Color(0xFF000000),
      surfaceTint: Color(0xFF3EC2CF),
      outline: Color(0xFF3EC2CF),
    );

    final isColumnMode = FluffyThemes.isColumnMode(context);
    return ThemeData(
      textTheme: Theme.of(context).textTheme.copyWith(
            bodyMedium: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.tertiary,
            ),
            bodySmall: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.tertiary,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'GothamRndSSm',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colorScheme.tertiary,
            ),
            titleLarge: TextStyle(
              fontFamily: 'GothamRndSSm',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorScheme.tertiary,
            ),
            titleSmall: TextStyle(
              fontFamily: 'GothamRndSSm',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.tertiary,
            ),
            labelSmall: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
      splashColor: colorScheme.primary.withValues(alpha: 0.1),
      visualDensity: VisualDensity.standard,
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      dividerColor: colorScheme.onSecondaryContainer,
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        iconColor: colorScheme.onSurface,
        textStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          iconColor: colorScheme.onPrimary,
          selectedBackgroundColor: colorScheme.primary,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colorScheme.onSurface.withAlpha(128),
        selectionHandleColor: colorScheme.secondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.surface, width: 0.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.surface),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.surface),
        ),
        labelStyle: TextStyle(
          fontFamily: 'GothamRndSSm',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSecondaryContainer,
        ),
        prefixIconColor: colorScheme.onSecondaryContainer,
      ),
      // cor dos chips
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
        selectedColor: colorScheme.primary.withValues(alpha: 0.6),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        labelStyle: TextStyle(
          color: colorScheme.tertiary,
        ),
      ),
      appBarTheme: AppBarTheme(
        toolbarHeight: isColumnMode ? 72 : 56,
        shadowColor: null,
        surfaceTintColor: Colors.transparent,
        backgroundColor: isColumnMode ? colorScheme.surface : null,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness.reversed,
          statusBarBrightness: brightness,
          systemNavigationBarIconBrightness: brightness.reversed,
          systemNavigationBarColor: colorScheme.surface,
        ),
        foregroundColor: colorScheme.tertiary,
        iconTheme: IconThemeData(
          color: colorScheme.tertiary, // escolha a cor que quiser
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            width: 1,
            color: colorScheme.surface,
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colorScheme.surface),
            borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          ),
        ),
      ),
      snackBarTheme: isColumnMode
          ? const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              width: FluffyThemes.columnWidth * 1.5,
            )
          : const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.surface,
          elevation: 0,
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: colorScheme.primary.withOpacity(0.6),
        iconColor: colorScheme.primary.withOpacity(0.6),
        selectedColor: colorScheme.primary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        titleTextStyle: TextStyle(
            fontFamily: 'GothamRndSSm',
            color: colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w400),
        contentTextStyle: TextStyle(
          color: colorScheme.onSecondaryContainer,
          decorationColor: colorScheme.onSurface,
        ),
      ),
    );
  }
}

extension on Brightness {
  Brightness get reversed =>
      this == Brightness.dark ? Brightness.light : Brightness.dark;
}

// cor das mensagens
extension BubbleColorTheme on ThemeData {
  Color get bubbleColor => brightness == Brightness.light
      ? colorScheme.secondary
      : colorScheme.secondary.withValues(alpha: 1);

  Color get onBubbleColor => colorScheme.onSecondary;

  Color get secondaryBubbleColor => brightness == Brightness.light
      ? colorScheme.tertiary
      : colorScheme.secondary.withValues(alpha: 0.5);
}

extension ColorId on ColorScheme {
  // logos
  String get logoHorizontalSemFundo => 'assets/logo_horizontal_semfundo.png';
  String get logoSingleSemFundo => 'assets/logo_single_semfundo.png';

  // geral
  Color get normalSnackBarTextColor => tertiary;
  Color get oopsMessageTextColor => onSecondaryContainer;

  // login and register
  Icon get loginSenhaIconCadeado => Icon((Icons.lock_outlined));
  String get loginFontFamily => "Roboto";
  Color get loginBoxBackground => tertiary;
  Color get loginLabel => onSurface;
  Color get userTxtFieldTextColor => onSurface;
  Color get userTxtFieldFilledColor => tertiary;
  Color get userTxtFieldBorderColor => primary;
  Color get eyeIconPasswordVisibility => primary;
  Color get loginButtonTextColor => tertiary;
  Color get loginNewHereTextColor => onSurface;
  Color get loginCreateAccTextColor => primary;
  Color get loginPasswordForgottenTextColor => primary;
  Color get loginAbove18CheckBoxActiveColor => secondary;
  Color get loginAbove18CheckBoxCheckColor => tertiary;
  Color get loginIsAdultTextColor => onSurface;

  // menu login
  Icon get menuIconStore => Icon(
        Icons.shopping_cart,
        color: loginMenuIconColor,
        size: 20,
      );

  Icon get menuIconCourse => Icon(
        Icons.book,
        color: loginMenuIconColor,
        size: 20,
      );

  Icon get menuIconPodcast => Icon(
        Icons.mic,
        color: loginMenuIconColor,
        size: 20,
      );

  Icon get menuIconInfo => Icon(
        Icons.info_outlined,
        color: loginMenuIconColor,
      );

  Color get loginMenuIconColor => primary;
  Color get loginMenuTextColor => onSurface;

  // login scaffold
  List<Color> get gradientBackground => [
        surfaceContainerLow,
        surfaceContainer,
        surfaceContainerHighest,
      ];
  Color get scaffoldBorderColor => primary;

  // chatlist 
  // discover 
  Color get chatlistDiscoverTextColor => tertiary;
  Color get chatlistDiscoverRoomTileGroupNameTextColor => tertiary;
  Color get chatlistDiscoverRoomTilePriceDescriptionTextColor => tertiary;
  Color get chatlistDiscoverRoomTileBackgroundColor => secondary.withValues(alpha: 0.4);
  Color get chatlistDiscoverRoomTileDescriptionTextColor => onSecondaryContainer;
  Color get chatlistDiscoverRoomButtonTextColor => tertiary;
  Color get chatlistDiscoverRoomAccessButtonColor => secondary;
  Color get chatlistDiscoverRoomButtonColor => primary.withValues(alpha: 0.6);

  
  Color get chatlistDiscoverBundleTileGroupNameTextColor => tertiary;
  Color get chatlistDiscoverBundleTilePriceDescriptionTextColor => tertiary;
  Color get chatlistDiscoverBundleTileBackgroundColor => Color.fromARGB(255, 109, 100, 209).withValues(alpha: 0.4);
  Color get chatlistDiscoverBundleTileDescriptionTextColor => onSecondaryContainer;
  Color get chatlistDiscoverBundleButtonTextColor => tertiary;
  Color get chatlistDiscoverBundleAccessButtonColor => Color.fromARGB(255, 109, 100, 209);
  Color get chatlistDiscoverBundleButtonColor => primary.withValues(alpha: 0.6);

  // new private chat
  Color get newPrivateTextColor => tertiary;
  Color get newPrivateBorderColor => primary;
  Color get newPrivateQRCodeColor => primary;
  Color get newPrivateBackgroundColor => surface;
  Color get newPrivateTextFieldFilledColor => tertiaryContainer;
  Color get newPrivateTextFieldHintColor => onSecondaryContainer;
  Color get newPrivateTextFieldTextColor => tertiary;
  Color get newPrivateListTileBackgroundColor => primary;
  Color get newPrivateListTileTextColor => tertiary;
  Color get newPrivateNoFoundTextColor => onSecondaryContainer;
  Color get newPrivateUserNameTextColor => primary;
  Color get newPrivateUserIdTextColor => tertiary;

  // new Group
  Color get newGroupSwitchActiveColor => primary;
  Color get newGroupSwitchInactiveColor => tertiaryContainer;
  Color get newGroupOptionsTextColor => tertiary;
  Color get newGroupPhotoTemplateBackgroundColor => primary;
  Color get newGroupPhotoTemplateIconColor => tertiary;
  Color get newGroupButtonSegmentSelectedTextColor => surface;
  Color get newGroupButtonSegmentUnselectedTextColor => primary;
  Color get newGroupTextFieldFilledColor => tertiaryContainer;
  Color get newGroupTextFieldHintColor => onSecondaryContainer;
  Color get newGroupTextFieldTextColor => tertiary;

  // view
  Color get chatListBackground => surface;

  // list popup (options to mute, notread, etc)
  Color get chatListPopupBackground => surface;
  Color get chatListPopupTextColor => tertiary;
  Color get chatListPopupIconColor => tertiary;

  // header
  Color get navigationSearchTextColor => onSecondary;
  Color get navigationSearchFilledColor => tertiaryContainer;
  Color get navigationSearchHintTextColor => onSecondary;
  Color get navigationSearchIconColor => onSecondary;
  Color get circularProgressIndicatorColor => primary;

  // client chooser button
  Icon get iconEdit => Icon(
        Icons.edit_outlined,
        color: clientChooserButtonIconColor,
        size: 22,
      );

  Icon get iconHome => Icon(
        Icons.home,
        color: clientChooserButtonIconColor,
        size: 22,
      );

  Icon get iconCourse => Icon(
        Icons.book,
        color: clientChooserButtonIconColor,
        size: 22,
      );

  Icon get iconSetting => Icon(
        Icons.settings,
        color: clientChooserButtonIconColor,
        size: 22,
      );

  Icon get iconInfo => Icon(
        Icons.info_outlined,
        color: clientChooserButtonIconColor,
        size: 22,
      );

  Icon get iconShare => Icon(
        Icons.adaptive.share_outlined,
        color: clientChooserShareIconColor,
        size: 22,
      );

  Color get clientChooserButtonIconColor => tertiary;
  Color get clientChooserButtonTextColor => tertiary;
  Color get clientChooserShareIconColor => primary;
  Color get clientChooserShareTextColor => primary;

  // show about info
  String get showAboutInfoFontFamily => 'GothamRndSSm';
  Color get showAboutInfoTitleColor => primary;
  Color get showAboutInfoSourceTextColor => tertiary;

  // body
  // searchtile (disabled)
  Color get searchTitleBackGroud => surface;
  Color get searchTitleIconColor => primary;
  Color get noChatsFoundIconColor => onSecondaryContainer;
  Color get noChatsFoundTextColor => onSecondaryContainer;
  Color get typingIconBaseColor => surface;
  Color get typingIconBallsColor => secondary;

  // item
  String get chatNameFontFamily => "GothamRndSSm";
  Color get activeChatBackground => primary.withValues(alpha: 0.2);
  Color get dropDownIconColor => primary;
  Color get dropDownDetailIconColor => tertiary;
  Color get chatNameTextColor => primary;
  Color get chatStatusIconColor => primary;
  Color get localizedTimeShortColor => onSecondary;
  Color get chatItemIconColor => tertiary;
  Color get chatItemTextColor => tertiary;
  Color get chatItemUnreadColor => primary;

  // navirail
  Icon get navirailIconHomeUnselected => Icon(
        Icons.home,
        color: unselectediconColor,
        size: 40,
      );

  Icon get navirailIconChatUnselected => Icon(
        Icons.chat_bubble_outline,
        color: unselectediconColor,
        size: 40,
      );

  Icon get navirailIconChatSelected => Icon(
        Icons.chat_bubble_outline,
        color: selectediconColor,
        size: 40,
      );

  Icon get navirailIconCourseUnselected => Icon(
        Icons.book,
        color: unselectediconColor,
        size: 40,
      );

  Icon get navirailIconSettingUnselected => Icon(
        Icons.settings,
        color: unselectediconColor,
        size: 40,
      );

  Icon get navirailIconSettingSelected => Icon(
        Icons.settings,
        color: selectediconColor,
        size: 40,
      );

  Color get selectedContainerColor => primary;
  Color get selectediconColor => primary;
  Color get unselectediconColor => tertiary;

  // chat
  // input bar
  Color get inputBarBackground => surfaceContainerHigh;
  Color get sendIconColor => tertiary;
  Color get sendPaddingColor => secondary; //MOSTRA ESSE
  Color get textSelectionColor => onTertiaryContainer;
  Color get answerAndShareButtonTextColor => onSecondaryContainer;
  Color get answerAndShareIconColor => onSecondaryContainer;
  Color get addCirclePopupBackground => surface;
  Color get addCircleAndEmojiIconColor => tertiary;
  Color get addCirclePopupTextColor => tertiary;
  Color get addCirclePopupIconColor => tertiary;
  Color get addCirclePopupIconPaddingColor => surface;
  Color get messageInputTextColor => tertiary;

  // send file
  Color get fileTypeTextColor => onSecondaryContainer;
  Color get fileCompressionSwitchActiveColor => primary;
  Color get fileCompressionSwitchInactiveColor => tertiaryContainer;
  Color get fileCompressionTextColor => onSecondaryContainer;

  // answer
  Color get senderNameBeingAnsweredTextColor => secondary;
  Color get messageBeingAnsweredTextColor => tertiary;
  Color get closeMessageBeingAnsweredIconColor => onSecondary;

  // edit
  Color get editMessageIconColor => secondary;

  // emoji picker
  Color get emojiTabSelectedColor => primary;
  Color get emojitabUnselectedColor => primary.withAlpha(128);
  Color get emojiIconSelectedColor => primary;
  Color get emojiIconUnselectedColor => primary.withAlpha(128);
  Color get emojiPickerBackground => surface;
  Color get emojiPickerIndicator => onSurface;
  Color get emojiIconTextColor => tertiary;

  // bar
  String get chatAppBarFontFamily => "GothamRndSSm";
  Color get chatAppBarTileTextColor => tertiary;
  Color get chatAppBarTileIconColor => tertiary;
  Color get chatAppBarTileChatNameTextColor => primary;
  Color get chatAppBarTileBackground => surface;
  Color get chatAppBarTileSelectedBackground => tertiaryContainer;
  Color get chatAppBarBackButtonColor => onSecondaryContainer;
  Color get jumpToLastMessagePaddingColor => secondary;

  // info about the message
  Color get infoAboutMessageTextColor => tertiary;
  Color get infoAboutMessageBackground => surface;

  // body
  Color get chatBackground => tertiary;

  //  message
  Color get reactionBarBackground => surface;
  Color get seenByBackground => surface;
  Color get messageTextColor => tertiary;
  Color get messageReadUpToHereColor => secondary.withOpacity(0.6);
  Color get reactionBarMoreReactionIconColor => onSecondaryContainer;
  Color get reactionTextColor => onSurface;
  Color get reactionInkColor => primaryContainer;
  Color get selectionMessageColor => primaryContainer.withValues(alpha: 0.5);

  // reaction popup
  Color get reactionPopupTextColor => tertiary;

  // pinned message
  Color get pinnedMessageBackground => surface;
  Color get pinnedMessageIconColor => primary;
  Color get pinnedMessageTextColor => tertiary;
  Color get pinnedMessageButtonColor => primary.withValues(alpha: 0.8);

  // chat events (ex: amigo alterou o avatar do chat)
  Color get eventBubbleBackground => secondary.withOpacity(0.6);
  Color get eventBubbleTextColor => tertiary;
  Color get eventBubbleMoreEventsTextColor => secondary;

  // livestream
  Color get liveStreamBackground => surface;
  Color get liveStreamIconColor => onSecondaryContainer;
  Color get liveStreamTitleColor => onSecondary;
  Color get liveStreamMenuTextColor => tertiary;

  // vods popup
  String get vodsPopupFontFamily => 'GothamRndSSm';
  Color get vodsPopupBackground => surface;
  Color get vodsPopupHandleColor => primary;
  Color get vodsPopupMainTagTextColor => primary;
  Color get vodsCategoryTagTextColor => tertiary;
  Color get vodsBackButtonColor => primary;
  Color get vodsShowMoreColor => primary;
  String get vodCardFontFamily => 'Roboto';
  Color get vodCardBackgroundColor => surface;
  Color get vodCardTextColor => tertiary;
  Color get vodCardIconColor => tertiary;
  Color get vodCardDateChipColor => secondary.withOpacity(0.2);
  Color get vodCardCategoryChipColor => primary.withOpacity(0.2);

  // vod screen
  Color get vodScreenBackButtonColor => tertiary;

  // text input dialog
  Color get textInputDialogTitleTextColor => primary;

  // dialog text field
  String get dialogTextFieldFontFamily => 'Roboto';
  Color get dialogTextFieldTextColor => tertiary;
  Color get dialogTextFieldBackground => tertiaryContainer;
  Color get dialogTextFieldBorderColor => surface;
  Color get dialogTextFieldHintTextColor => onSecondaryContainer;
  Color get dialogTextFieldSuffixPrefixColor => primary;

  // ok cancel alert dialog
  Color get okCancelAlertTitleTextColor => primary;
  Color get okCancelAlertMessageTextColor => onSecondaryContainer;
  Color get okCancelAlertOkButtonColor => primary;

  // alert dialog (default: AlertDialogTheme)
  Color get alertDialogBackground => surface;
  Color get alertDialogAreYouSureTextColor => primary;
  Color get alertDialogDescriptionTextColor => onSecondaryContainer;
  Color get alertDialogCancelTextColor => primary;

  // details
  Color get detailsBackButtonColor => tertiary;
  Color get detailsIconColor => tertiary;
  Color get detailsMainIconColor => primary;
  Color get detailsTextColor => tertiary;
  Color get photoChooserButtonPaddingColor => primary;
  Color get photoChooserButtonIconColor => tertiary;
  String get detailFontFamily => 'GothamRndSSm';
  Color get detailChatNameTextColor => primary;
  Color get detailDescriptionButtonColor => primary;
  Color get detailDescriptionTextColor => onSecondaryContainer;
  Color get detailParticipantsTextColor => primary;
  Color get detailParticipantsInvitePaddingColor => secondary;
  Color get detailParticipantsInviteIconColor => tertiary;

  // participants
  String get participantsFontFamily => 'GothamRndSSm';
  Color get participantNameTextColor => primary;
  Color get participantPowerLevelabove100MainColor => primary;
  Color get participantPowerLevelbelow100MainColor => secondary;
  Color get participantPowerLevelTextColor => tertiary;
  Color get participantTextColor => tertiary;
  Color get participantScreenBackButton => tertiary;
  Color get participantScreenTitle => tertiary;

  // popup
  Color get participantApproveTextColor => tertiary;
  Color get participantLevelIconColor => primary;

  // search
  Color get searchScreenBackButton => tertiary;
  Color get searchScreenTitle => tertiary;
  Color get searchScreenTabBarSelected => primary;
  Color get searchScreenTabBarUnelected => primary.withAlpha(128);
  Color get searchTextButtonPaddingColor => primary;
  Color get searchTextButtonTextColor => tertiary;
  Color get searchFileIconColor => secondary;
  Color get searchMessageSearchColor => onSecondaryContainer;

  //extensions
  Color get extensionScreenBackButton => tertiary;
  Color get extensionScreenTextColor => tertiary;
  Color get availableExtensionTextColor => primary;
  Color get extensionBorderColorHovered => primary;
  Color get extensionBorderColorNotHovered => tertiary;
  Color get extensionIconColor => primary;
  Color get extensionIconText => tertiary;
  Color get extensionSubtitleText => onSecondaryContainer;

  // live preview dialog
  Color get livePreviewTitleColor => primary;
  Color get livePreviewIconColor => primary;
  Color get livePreviewLiveTitleColor => tertiary;
  Color get liveTextButtonPaddingColor => primary;
  Color get liveTextButtonTextColor => tertiary;

  // emojis and stickers
  Color get emojisAndStickersScreenBackButton => tertiary;
  Color get emojisAndStickersScreenTextColor => tertiary;
  Color get emojisAndStickersTextColor => tertiary;
  Color get emojisAndStickersBorderColor => tertiary;
  Color get emojisAndStickersIconColor => primary;
  Color get emojisAndStickersSwitchActiveColor => primary;
  Color get emojisAndStickersSwitchInactiveColor => tertiaryContainer;

  // access and visibility
  Color get accessScreenBackButton => tertiary;
  Color get accessScreenTextColor => tertiary;
  Color get accessScreenHintTextColor => onSecondary;
  Color get accessScreenTagColor => primary;
  Color get accessTextColor => tertiary;
  Color get accessDividerColor => primary;
  Color get accessSwitchActiveColor => primary;
  Color get accessSwitchInactiveColor => tertiaryContainer;
  Color get accessStarColor => primary;

  // permissions
  Color get permissionsScreenBackButton => tertiary;
  Color get permissionsScreenTextColor => tertiary;
  Color get permissionsInfoTextColor => onSecondaryContainer;
  Color get permissionsDividerColor => primary;
  Color get permissionsScreenTagColor => primary;
  Color get permissionsTextColor => tertiary;

  // permissions colors
  Color get permissionsPowerLevelabove100MainColor => primary;
  Color get permissionsPowerLevelabove50MainColor => secondary;
  Color get permissionsPowerLevelabove0MainColor => primaryFixed;

  // invitation
  Color get invitationScreenBackButton => tertiary;
  Color get invitationScreenTextColor => tertiary;

  // music player
  Color get sliderBaseColor => onPrimary;
  Color get sliderPlayedColor => primary;
  Color get musicPlayerBackground => tertiaryContainer;
  Color get musicPlayerTextColor => tertiary;
  Color get isPlayingColor => primary;
  Color get progressBarColor => primary;
  Color get progressBaseColor => onTertiary;
  Color get timeLabelsTextColor => onSecondaryContainer;

  // settings
  Color get settingScreenBackButton => tertiary;
  Color get floatingButtonPaddingColor => primary;
  Color get floatingButtonIconColor => tertiary;
  Color get settingTextColor => tertiary;
  Color get floatingButtonBackground => surface;

  // device setting
  Color get deviceSettingTitleColor => primary;
  Color get deviceSettingBackButtonColor => tertiary;
  Color get deviceSettingInfoColor => onSecondaryContainer;
  Color get deviceSettingTextColor => tertiary;
  Color get deviceSettingPaddingColor => secondary;
}
