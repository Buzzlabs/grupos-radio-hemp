import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matrix/matrix.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/widgets/layouts/login_scaffold.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'login.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/widgets/menu_login_options.dart';

class LoginView extends StatelessWidget {
  final LoginController controller;
  final bool enforceMobileMode;
  final Client client;

  const LoginView(
    this.controller, {
    super.key,
    this.enforceMobileMode = false,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobileMode =
        enforceMobileMode || !FluffyThemes.isColumnMode(context);

    final screenHeight = MediaQuery.of(context).size.height;

    final mobileAppBarHeight = screenHeight * 0.15;
    final mobileAppBarTitlePaddingTop = mobileAppBarHeight - 18;
    final mobileImagePadding = screenHeight * 0.03;

    const desktopAppBarHeight = 80.0;
    const desktopAppBarTitlePaddingTop = 30.0;
    const desktopImagePadding = 45.0;

    final toolBarHeight =
        isMobileMode ? mobileAppBarHeight : desktopAppBarHeight;
    final toolBarPadding = isMobileMode
        ? mobileAppBarTitlePaddingTop
        : desktopAppBarTitlePaddingTop;
    final imagePadding =
        isMobileMode ? mobileImagePadding : desktopImagePadding;

    return LoginScaffold(
      appBar: AppBar(
        backgroundColor: isMobileMode
            ? theme.colorScheme.loginBoxBackground
            : theme.colorScheme.loginBoxBackground,

        toolbarHeight: toolBarHeight,
        title: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            // top: toolBarPadding,
          ),
          child: Align(
            alignment: isMobileMode ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(
              L10n.of(context).login,
              style: TextStyle(
                fontFamily: theme.colorScheme.loginFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.colorScheme.loginLabel,
              ),
            ),
          ),
        ),
        actions: const [
          MoreLoginMenuButton(
            padding: EdgeInsets.only(right: 16.0, ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: imagePadding),
                      child: FractionallySizedBox(
                        widthFactor: isMobileMode ? 0.8 : 0.7,
                        child: Image.asset(
                          theme.colorScheme.logoHorizontalSemFundo,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextField(
                        style: TextStyle(
                          color: theme.colorScheme.userTxtFieldTextColor,
                          fontWeight: FontWeight.normal,
                          fontFamily: theme.colorScheme.loginFontFamily,
                        ),
                        readOnly: controller.loading,
                        autocorrect: false,
                        onChanged: controller.checkWellKnownWithCoolDown,
                        controller: controller.usernameController,
                        focusNode: controller.usernameFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: controller.loading
                            ? null
                            : [AutofillHints.username],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.account_box_outlined),
                          fillColor: theme.colorScheme.userTxtFieldFilledColor,
                          disabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.colorScheme.userTxtFieldBorderColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.userTxtFieldBorderColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.userTxtFieldBorderColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.userTxtFieldBorderColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error, 
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: controller.usernameError,
                          errorStyle: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 15,),
                          labelText: L10n.of(context).emailOrUsername,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextField(
                        style: TextStyle(
                          color: theme.colorScheme.userTxtFieldTextColor,
                          fontWeight: FontWeight.normal,
                          fontFamily: theme.colorScheme.loginFontFamily,
                        ),
                        readOnly: controller.loading,
                        autocorrect: false,
                        autofillHints: controller.loading
                            ? null
                            : [AutofillHints.password],
                        controller: controller.passwordController,
                        focusNode: controller.passwordFocusNode,
                        textInputAction: TextInputAction.go,
                        obscureText: !controller.showPassword,
                        onSubmitted: (_) => controller.login(),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outlined),
                          fillColor: theme.colorScheme.userTxtFieldFilledColor,
                          disabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.colorScheme.userTxtFieldBorderColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.userTxtFieldBorderColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.userTxtFieldBorderColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.userTxtFieldBorderColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error, 
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.userTxtFieldBorderColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                          errorText: controller.passwordError,
                          errorStyle: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 15,
                          ),
                          suffixIcon: IconButton(
                            onPressed: controller.toggleShowPassword,
                            icon: Icon(
                              controller.showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Theme.of(context).colorScheme.eyeIconPasswordVisibility,
                            ),
                          ),
                          labelText: L10n.of(context).password,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              controller.loading ? null : controller.login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          child: controller.loading
                              ? const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: LinearProgressIndicator(),
                                )
                              : Text(
                                  L10n.of(context).login,
                                  style: TextStyle(fontSize: 16, color: theme.colorScheme.loginButtonTextColor),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${L10n.of(context).newHere} ',
                                style: TextStyle(
                                  fontFamily: theme.colorScheme.loginFontFamily,
                                  color:
                                      Theme.of(context).colorScheme.loginNewHereTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: L10n.of(context).createAnAccountPrompt,
                                style: TextStyle(
                                  fontFamily: theme.colorScheme.loginFontFamily,
                                  color: Theme.of(context).colorScheme.loginCreateAccTextColor,
                                  fontSize: 18,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.normal,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.go('/register', extra: client);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: controller.loading
                              ? null
                              : controller.passwordForgotten,
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.loginPasswordForgottenTextColor,
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          child: Text(
                            L10n.of(context).passwordForgotten,
                            style: TextStyle(
                              fontFamily: theme.colorScheme.loginFontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
