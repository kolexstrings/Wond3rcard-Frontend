import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wond3rcard/src/onboarding/views/widgets/desktop_onboarding_constant_widget.dart';
import 'package:wond3rcard/src/utils/size_constants.dart';
import 'package:wond3rcard/src/utils/wonder_card_colors.dart';
import 'package:wond3rcard/src/utils/wonder_card_strings.dart';
import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:wond3rcard/src/authentication/data/controller/auth_controller.dart';
import 'package:wond3rcard/src/onboarding/views/widgets/continue_widget.dart';
import 'package:wond3rcard/src/shared/views/widgets/wonder_card_design_system/wonder_card_textfield.dart';
import 'package:wond3rcard/src/utils/assets.dart';

class OtpVerificationDesktop extends HookConsumerWidget {
  const OtpVerificationDesktop({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(flex: 2, child: getStartedStack(context)),
          Spacer(),
          Expanded(flex: 3, child: OtpData()),
        ],
      ),
    );
  }
}

class OtpData extends HookConsumerWidget {
  const OtpData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authProvider);

    final ValueNotifier<int> secondsLeft = useState(60);
    final ValueNotifier<bool> canResendOtp = useState(false);

    void startTimer() {
      canResendOtp.value = false;
      secondsLeft.value = 60;

      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (secondsLeft.value > 0) {
          secondsLeft.value--;
        } else {
          timer.cancel();
          canResendOtp.value = true;
        }
      });
    }

    void resendOtp() {
      ref.watch(authProvider).requestAccountVerfication(
          email: authController.emailController.text);
      print('this is the email ${authController.emailController.text}');
      startTimer();
    }

    useEffect(() {
      startTimer();
      return null;
    }, []);

    return Container(
      padding: EdgeInsets.only(right: 80,),
      margin: EdgeInsets.only(right: 50,),
      width: MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            ImageAssets.checkEmail,
            width: SpacingConstants.size95,
            height: SpacingConstants.size100,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: SpacingConstants.size20),
          const Text(
            checkYourEmailText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingConstants.size10),
          const Text(
            weHaveSendCodeText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingConstants.size20),
          SizedBox(
             width: MediaQuery.of(context).size.width / 4,
            child: CustomTextField(
              type: TextFieldType.Email,
              inputType: TextInputType.emailAddress,
              text: enterWorkEmail,
              hintText: enterYourEmailText,
              textEditingController: authController.emailController,
            ),
          ),
          SizedBox(
             width: MediaQuery.of(context).size.width / 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _pinCode(authController.pinCode1, context,
                    nextFocus: authController.pinCode2),
                _pinCode(authController.pinCode2, context,
                    nextFocus: authController.pinCode3),
                _pinCode(authController.pinCode3, context,
                    nextFocus: authController.pinCode4),
                _pinCode(authController.pinCode4, context,
                    nextFocus: authController.pinCode5),
                _pinCode(authController.pinCode5, context,
                    nextFocus: authController.pinCode6),
                _pinCode(authController.pinCode6, context, nextFocus: null),
              ],
            ),
          ),
          const SizedBox(height: SpacingConstants.size20),
          SizedBox(
             width: MediaQuery.of(context).size.width / 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                    width: SpacingConstants.size16,
                    height: SpacingConstants.size16,
                    child: CircularProgressIndicator.adaptive()),
                const SizedBox(width: SpacingConstants.size5),
                ValueListenableBuilder<int>(
                  valueListenable: secondsLeft,
                  builder: (context, value, _) {
                    final minutes = (value ~/ 60).toString();
                    final seconds = (value % 60).toString().padLeft(2, '0');
                    return Text('$minutes:$seconds',
                        style: Theme.of(context).textTheme.bodyLarge);
                  },
                ),
                const SizedBox(width: SpacingConstants.size10),
                ValueListenableBuilder<bool>(
                  valueListenable: canResendOtp,
                  builder: (context, value, _) {
                    return TextButton(
                      onPressed: value ? resendOtp : null,
                      child: Text(
                        'resend',
                        style: TextStyle(
                          color: value ? AppColors.primaryShade : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingConstants.size20),
          SizedBox(
             width: MediaQuery.of(context).size.width / 4,
            child: ContinueWidget(
              showLoader: authController.loading,
              onTap: () {
                context.go(RouteString.signup);
              },
              bgColor: AppColors.primaryShade,
              textColor: AppColors.defaultWhite,
              onPress: () {
                authController.otpInputMethod(
                    authController.pinCode1,
                    authController.pinCode2,
                    authController.pinCode3,
                    authController.pinCode4,
                    authController.pinCode5,
                    authController.pinCode6,
                    ref,
                    authController.emailController.text,
                    context);
              },
              buttonText: confirmText,
            ),
          )
        ],
      ),
    );
  }

  SizedBox _pinCode(
    TextEditingController controller,
    BuildContext context, {
    TextEditingController? nextFocus,
  }) {
    return SizedBox(
      width: SpacingConstants.size52,
      child: CustomTextField(
        textEditingController: controller,
        hintText: '-',
        borderColor: AppColors.borderPrimary,
        borderRadius: SpacingConstants.size8,
        textAlign: TextAlign.center,
        maxLines: 1,
        onChange: (value) {
          if (value.isNotEmpty && nextFocus != null) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
