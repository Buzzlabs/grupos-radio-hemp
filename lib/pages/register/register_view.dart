import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matrix/matrix.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/widgets/layouts/login_scaffold.dart';
import 'register.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:fluffychat/widgets/menu_login_options.dart';

class RegisterView extends StatelessWidget {
  final RegisterController controller;
  final bool enforceMobileMode;
  final Client client;

  const RegisterView(
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
    final imagePadding = mobileImagePadding;
        // isMobileMode ? mobileImagePadding : desktopImagePadding;

    return LoginScaffold(
      appBar: AppBar(
        backgroundColor: isMobileMode
            ? theme.colorScheme.loginBoxBackground
            : theme.colorScheme.loginBoxBackground,
        toolbarHeight: toolBarHeight,
        title: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
          ),
          child: Align(
            alignment: isMobileMode ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(
              L10n.of(context).signUp,
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
            padding: EdgeInsets.only(right: 16.0),
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
                      padding: isMobileMode? EdgeInsets.only(bottom: imagePadding): EdgeInsets.symmetric(vertical: imagePadding),
                      child: FractionallySizedBox(
                        widthFactor: isMobileMode ? 0.8 : 0.7,
                        child: Image.asset(
                          'assets/logo_horizontal_semfundo.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),

                    // EMAIL
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextField(
                        style: TextStyle(
                          color: theme.colorScheme.userTxtFieldBorderColor,
                          fontFamily: theme.colorScheme.loginFontFamily,
                        ),
                        readOnly: controller.loading,
                        autocorrect: false,
                        controller: controller.emailController,
                        focusNode: controller.emailFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
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
                          errorText: controller.emailError,
                          labelText: L10n.of(context).email,
                        ),
                      ),
                    ),

                    // USERNAME
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextField(
                        style: TextStyle(
                          color: theme.colorScheme.userTxtFieldTextColor,
                          fontFamily: theme.colorScheme.loginFontFamily,
                        ),
                        readOnly: controller.loading,
                        autocorrect: false,
                        controller: controller.usernameController,
                        focusNode: controller.usernameFocusNode,
                        textInputAction: TextInputAction.next,
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
                          errorText: controller.usernameError,
                          labelText: L10n.of(context).username,
                        ),
                      ),
                    ),

                    // PASSWORD
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextField(
                        style: TextStyle(
                          color: theme.colorScheme.userTxtFieldTextColor,
                          fontFamily: theme.colorScheme.loginFontFamily,
                        ),
                        readOnly: controller.loading,
                        controller: controller.passwordController,
                        focusNode: controller.passwordFocusNode,
                        textInputAction: TextInputAction.go,
                        obscureText: !controller.showPassword,
                        onSubmitted: (_) => controller.register(),
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
                          errorText: controller.passwordError,
                          suffixIcon: IconButton(
                            onPressed: controller.toggleShowPassword,
                            icon: Icon(
                              controller.showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: theme.colorScheme.eyeIconPasswordVisibility,
                            ),
                          ),
                          labelText: L10n.of(context).password,
                        ),
                      ),
                    ),

                    // IS ADULT
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: controller.isAdult,
                            activeColor: theme.colorScheme.loginAbove18CheckBoxActiveColor,
                            checkColor: theme.colorScheme.loginAbove18CheckBoxActiveColor,
                            onChanged: controller.toggleIsAdult,
                          ),
                          Text(
                            L10n.of(context).isAdult,
                            style: TextStyle(
                              fontFamily: theme.colorScheme.loginFontFamily,
                              color: theme.colorScheme.loginIsAdultTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // REGISTER BUTTON
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              controller.loading ? null : controller.register,
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
                                  L10n.of(context).createAccount,
                                  style: TextStyle(fontSize: 16, color: theme.colorScheme.loginButtonTextColor,),
                                ),
                        ),
                      ),
                    ),

                    // GO BACK TO LOGIN
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${L10n.of(context).alreadyHaveAccount} ',
                              style: TextStyle(
                                fontFamily: theme.colorScheme.loginFontFamily,
                                color: theme.colorScheme.loginNewHereTextColor,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text: L10n.of(context).login,
                              style: TextStyle(
                                fontFamily: theme.colorScheme.loginFontFamily,
                                color: theme.colorScheme.loginCreateAccTextColor,
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.go('/login', extra: client);
                                },
                            ),
                          ],
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
