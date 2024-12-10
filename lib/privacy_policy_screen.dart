import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Effective Date: December 04, 2024"),
            _buildSectionHeader("Grads  Connect Privacy Policy"),
            _buildText(
                "This privacy policy applies to the Grads  Connect app (hereby referred to as \"Application\") for mobile devices that was created by Grads Gateway (hereby referred to as \"Service Provider\") as a Free service. This service is intended for use \"AS IS\"."
            ),

            _buildSectionHeader("Information Collection and Use"),
            _buildText(
                "The Application collects information when you download and use it. This information may include:"
            ),
            _buildBulletPoint("Your device's Internet Protocol address (e.g., IP address)."),
            _buildBulletPoint("The pages of the Application that you visit, the time and date of your visit, and the time spent on those pages."),
            _buildBulletPoint("The operating system you use on your mobile device."),
            _buildText(
                "The Application does not gather precise information about the location of your mobile device."
            ),
            _buildText(
                "The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices, and marketing promotions."
            ),

            _buildSectionHeader("Collecting and Using Your Personal Data"),
            _buildSectionHeader("Types of Data Collected"),
            _buildSubHeader("Personal Data"),
            _buildText(
                "While using Our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you. Personally identifiable information may include, but is not limited to:"
            ),
            _buildBulletPoint("Student’s Email address"),
            _buildBulletPoint("Student’s First name and Last name"),
            _buildBulletPoint("Student’s Phone number"),
            _buildBulletPoint("App User’s First name and Last name"),
            _buildBulletPoint("App User’s Phone number"),

            _buildSubHeader("Usage Data"),
            _buildText(
                "Usage Data is collected automatically when using the Service and may include information such as your Device's Internet Protocol address, browser type, browser version, the pages of our Service that you visit, and other diagnostic data."
            ),

            _buildSectionHeader("Third-Party Access"),
            _buildText(
                "Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may disclose information as required by law or in good faith belief that disclosure is necessary for legal purposes."
            ),

            _buildSectionHeader("Opt-Out Rights"),
            _buildText(
                "You can stop all collection of information by uninstalling the Application. Use the standard uninstall processes as available on your mobile device."
            ),

            _buildSectionHeader("Retention of Your Personal Data"),
            _buildText(
                "The Company will retain your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy."
            ),

            _buildSectionHeader("Delete Your Personal Data"),
            _buildText(
                "Users have the right to delete their accounts at any time. To request account deletion, please follow these steps:"
            ),
            _buildText("In-App Option:"),
            _buildBulletPoint("Navigate to the Delete Account menu option in the app."),
            _buildBulletPoint("Follow the on-screen instructions to confirm your request.."),
            _buildText("Contacting Support:"),
            _buildBulletPoint("If you are unable to delete your account via the app, you may contact our support team at contact@gradsgateway.com ."),
            _buildBulletPoint("Include your registered mobile number and a request for account deletion."),

            _buildText("Upon account deletion:"),
            _buildBulletPoint("All your personal data, including your profile information, will be permanently erased from our systems, except as required to comply with legal obligations or resolve disputes."),
            _buildBulletPoint("Some anonymized data may be retained for analytical purposes, but it will no longer be linked to your account."),
            _buildBulletPoint("It might take up to 7 working days to delete your personal data."),
            _buildBulletPoint("You will get an SMS with the Account deletion Service Request No. Please keep this for reference in case you would like to contact us for more information on the request status."),
            _buildText("If you have any questions about account deletion, feel free to contact us at contact@gradsgateway.com."),



            _buildSectionHeader("Children"),
            _buildText(
                "The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us."
            ),

            _buildSectionHeader("Security"),
            _buildText(
                "The Service Provider is concerned about safeguarding the confidentiality of your information. While we strive to use commercially acceptable means to protect your Personal Data, no method is 100% secure."
            ),
            _buildSectionHeader("Law enforcement"),
            _buildText(
                "Under certain circumstances, the Company may be required to disclose your Personal Data if required to do so by law or in response to valid requests by public authorities (e.g. a court or a government agency).Other legal requirements The Company may disclose your Personal Data in the good faith belief that such action is necessary to: "
            ),
            _buildBulletPoint("Comply with a legal obligation."),
            _buildBulletPoint("Protect and defend the rights or property of the Company.  "),
            _buildBulletPoint("Prevent or investigate possible wrongdoing in connection with the Service. "),
            _buildBulletPoint("Protect the personal safety of Users of the Service or the public."),
            _buildBulletPoint("Protect against legal liability."),

            _buildSectionHeader("Changes"),
            _buildText(
                "This Privacy Policy may be updated from time to time. Continued use of the Application is deemed approval of all changes."
            ),
            _buildSectionHeader("Your Consent"),
            _buildText("By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us."),

            _buildSectionHeader("Contact Us"),
            _buildText("If you have any questions, contact us at contact@gradsgateway.com."),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
      ),
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14.0),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.black),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }
}
