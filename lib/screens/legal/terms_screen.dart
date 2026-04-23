import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundBlobs(),
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 48),
                          _buildPartOne(),
                          const SizedBox(height: 64),
                          _buildPartTwo(),
                          const SizedBox(height: 80),
                          _buildDisclaimer(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background.withOpacity(0.8),
      floating: true,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'LEGAL',
        style: AppTextStyles.label(
          12,
          color: Colors.white,
          weight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      centerTitle: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MAINCHAR',
          style: AppTextStyles.headline(48, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          'Terms of Service & Privacy Policy',
          style: AppTextStyles.headline(24, weight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildInfoRow('Version', 'Demo / Pre-Launch'),
        _buildInfoRow('Effective Date', '[To Be Finalized Before Launch]'),
        _buildInfoRow('Governing Law', 'Punjab, Pakistan'),
        _buildInfoRow('Contact', 'demowork@gmail.com'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
          ),
          child: Text(
            'This document is a working draft for demonstration purposes only.',
            style: AppTextStyles.body(
              14,
              color: Colors.redAccent,
              weight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.body(14, color: AppColors.onSurfaceVariant),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPartTitle('PART ONE — TERMS OF SERVICE'),
        const SizedBox(height: 32),
        _buildSection(
          '1. Introduction & Acceptance',
          'Welcome to MainChar ("the Platform", "the App", "we", "us", or "our"). MainChar is a gamified social networking application designed exclusively for university and college student communities. By creating an account, accessing, or using the Platform, you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, you must not use the Platform.\n\nThese Terms constitute a legally binding agreement between you ("User", "you") and the developer/operator of MainChar, currently operating as a demo project governed by the laws of Punjab, Pakistan.',
        ),
        _buildSection('2. Eligibility', ''),
        _buildSubSection(
          '2.1 University Students Only',
          'MainChar is exclusively available to currently enrolled university or college students. By registering, you confirm that you are actively enrolled at a recognized university or college institution.',
        ),
        _buildSubSection(
          '2.2 Minimum Age',
          'You must be at least 18 years of age to use MainChar. By registering, you confirm that you meet this age requirement. We do not knowingly permit users under the age of 18. If we discover that a registered user is under 18, their account will be immediately suspended and deleted.',
        ),
        _buildSubSection(
          '2.3 Verification',
          'We reserve the right to request proof of enrollment or age at any time. Failure to provide satisfactory verification may result in account suspension.',
        ),
        _buildSection(
          '3. Account Registration',
          'To use MainChar, you must create an account. You agree to:\n'
              '• Provide accurate, current, and complete information during registration.\n'
              '• Keep your account credentials confidential and not share your password with anyone.\n'
              '• Notify us immediately at demowork@gmail.com if you suspect unauthorized access to your account.\n'
              '• Accept full responsibility for all activities that occur under your account.\n\n'
              'We reserve the right to refuse registration or suspend any account at our sole discretion.',
        ),
        _buildSection('4. User-Generated Content (UGC)', ''),
        _buildSubSection(
          '4.1 Your Content',
          'MainChar allows you to upload and share content, including profile pictures, usernames, bios, and activity/vibe tags (collectively, "Your Content"). You retain ownership of Your Content; however, by uploading it to the Platform, you grant MainChar a non-exclusive, royalty-free, worldwide, sublicensable license to use, display, reproduce, and distribute Your Content solely for the purpose of operating and improving the Platform.',
        ),
        _buildSubSection(
          '4.2 Content Standards',
          'You agree that Your Content will NOT:\n'
              '• Be defamatory, abusive, harassing, threatening, or constitute cyberbullying.\n'
              '• Contain nudity, sexually explicit material, or content of a sexual nature.\n'
              '• Promote violence, hatred, or discrimination based on race, religion, gender, ethnicity, nationality, sexual orientation, disability, or any other characteristic.\n'
              '• Infringe upon the intellectual property rights of any third party.\n'
              '• Contain false, misleading, or deceptive information.\n'
              '• Impersonate another person, whether a real individual or a fictional character.\n'
              '• Violate any applicable local, national, or international law or regulation.',
        ),
        _buildSubSection(
          '4.3 Content Moderation',
          'We take content moderation seriously. The Platform includes a user-facing report mechanism. Users may flag any content or profile that they believe violates these Terms. Upon receiving a report:\n'
              '• We will review flagged content within a reasonable timeframe.\n'
              '• Content confirmed to violate these Terms will be removed.\n'
              '• Users who repeatedly or severely violate content standards may be permanently banned.\n\n'
              'We reserve the right, but not the obligation, to proactively review, edit, or remove any content on the Platform at our sole discretion without notice.',
        ),
        _buildSection('5. The Voting Arena & Recognition System', ''),
        _buildSubSection(
          '5.1 How It Works',
          'The core mechanic of MainChar allows users to swipe on profile cards of other users to indicate whether they recognize them. This data is used to calculate a Recognition Score and populate a public Leaderboard.',
        ),
        _buildSubSection(
          '5.2 Consent to Appear',
          'By creating an account and making your profile active, you explicitly consent to:\n'
              '• Having your profile card shown to other users in the Voting Arena.\n'
              '• Having your Recognition Score calculated and publicly displayed on the Leaderboard.\n'
              '• Having anonymous vote counts associated with your profile.',
        ),
        _buildSubSection(
          '5.3 No Guarantee of Anonymity in Reveals',
          'MainChar includes a time-locked monthly reveal feature where users may see who has recognized them. By participating in the voting system (i.e., by swiping on others\' profiles), you acknowledge and consent to the possibility that your identity may be revealed to another user during a reveal window.',
        ),
        _buildSubSection(
          '5.4 No Misuse of the Voting System',
          'Users must not use the Voting Arena to harass, demean, or target specific individuals. Using the platform to organize coordinated negative voting against a specific user is strictly prohibited and may result in immediate account termination.',
        ),
        _buildSection(
          '6. Prohibited Activities',
          'In addition to the content standards above, you agree NOT to:\n'
              '• Attempt to access, tamper with, or disrupt the Platform\'s servers, database, or infrastructure.\n'
              '• Use automated scripts, bots, or scrapers to interact with the Platform.\n'
              '• Attempt to reverse-engineer, decompile, or disassemble any part of the Application.\n'
              '• Use the Platform for any commercial solicitation or spam.\n'
              '• Create multiple accounts to circumvent a ban or gain unfair advantages.\n'
              '• Share, sell, or transfer your account to another person.\n'
              '• Attempt to manipulate your own or another user\'s Recognition Score through artificial means.',
        ),
        _buildSection(
          '7. Intellectual Property',
          'All content on the Platform that is not User-Generated Content, including but not limited to the app\'s design, layout, logos, graphics, software, and text ("Platform Content"), is the exclusive intellectual property of the MainChar developer. You are granted a limited, non-exclusive, non-transferable license to use the Platform solely for personal, non-commercial purposes. You may not copy, reproduce, distribute, or create derivative works from Platform Content without explicit written permission.',
        ),
        _buildSection('8. Account Termination & Suspension', ''),
        _buildSubSection(
          '8.1 By Us',
          'We reserve the right to suspend or permanently terminate your account, with or without notice, for any reason, including but not limited to:\n'
              '• Violation of these Terms or our Acceptable Use standards.\n'
              '• Engaging in harassment, cyberbullying, or abusive behavior.\n'
              '• Providing false information during registration.\n'
              '• Attempting to compromise the security or integrity of the Platform.',
        ),
        _buildSubSection(
          '8.2 By You',
          'You may request to delete your account at any time by contacting us at demowork@gmail.com or using the in-app account deletion feature (where available). Please refer to our Privacy Policy for details on how your data is handled upon deletion.',
        ),
        _buildSection(
          '9. Disclaimers & Limitation of Liability',
          'THE PLATFORM IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, WE DISCLAIM ALL WARRANTIES, INCLUDING:\n'
              '• That the Platform will be uninterrupted, error-free, or secure.\n'
              '• That any content on the Platform is accurate, complete, or reliable.\n'
              '• That the Platform is free of viruses or other harmful components.\n\n'
              'TO THE MAXIMUM EXTENT PERMITTED BY LAW, MAINCHAR AND ITS DEVELOPER SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING OUT OF OR RELATED TO YOUR USE OF THE PLATFORM. THIS INCLUDES, WITHOUT LIMITATION, DAMAGES FOR LOSS OF REPUTATION, EMOTIONAL DISTRESS, OR DATA LOSS.',
        ),
        _buildSection(
          '10. Indemnification',
          'You agree to indemnify, defend, and hold harmless MainChar and its developer from and against any claims, liabilities, damages, losses, costs, and expenses (including reasonable legal fees) arising out of or in any way connected with: (a) your access to or use of the Platform; (b) Your Content; (c) your violation of these Terms; or (d) your violation of any rights of another person.',
        ),
        _buildSection(
          '11. Governing Law & Dispute Resolution',
          'These Terms shall be governed by and construed in accordance with the laws of Punjab, Pakistan, without regard to conflict of law principles. Any disputes arising out of or relating to these Terms or the Platform shall first be attempted to be resolved through good-faith negotiation. If unresolved, disputes shall be subject to the exclusive jurisdiction of the competent courts of Punjab, Pakistan.',
        ),
        _buildSection(
          '12. Changes to These Terms',
          'We reserve the right to modify these Terms at any time. We will notify registered users of material changes via in-app notification or email to the address associated with your account. Your continued use of the Platform after changes are posted constitutes your acceptance of the revised Terms. We encourage you to review these Terms periodically.',
        ),
        _buildSection(
          '13. Contact',
          'For questions, concerns, or legal notices regarding these Terms, please contact us at:\n\n'
              'Email: demowork@gmail.com\n'
              'Platform: MainChar (Demo Version)\n'
              'Jurisdiction: Punjab, Pakistan',
        ),
      ],
    );
  }

  Widget _buildPartTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPartTitle('PART TWO — PRIVACY POLICY'),
        const SizedBox(height: 32),
        _buildSection(
          '1. Introduction',
          'MainChar ("we", "us", "our") is committed to protecting the privacy of our users. This Privacy Policy explains how we collect, use, store, share, and protect your personal information when you use the MainChar application. By using the Platform, you consent to the practices described in this Privacy Policy.\n\nThis policy is governed by the laws of Punjab, Pakistan, and complies with applicable data protection principles under Pakistani law.',
        ),
        _buildSection('2. Information We Collect', ''),
        _buildSubSection(
          '2.1 Information You Provide Directly',
          '• Email Address: Collected during registration for account creation and communication.\n'
              '• Username / Display Name: Your chosen public identifier on the Platform.\n'
              '• Profile Photo: Uploaded from your device gallery or captured via your device camera.\n'
              '• Bio: A short text description you write about yourself.\n'
              '• Activity / Vibe Tags: Tags you select to represent your university interests (e.g., Sports, Tech, Music).',
        ),
        _buildSubSection(
          '2.2 Behavioral & Interaction Data',
          '• Voting / Swipe Data: The Platform records exactly which user profiles you have swiped on and whether you indicated recognition or not.\n'
              '• Recognition Score: A calculated score derived from votes received, stored and updated in our database.\n'
              '• Timestamps: Date and time of voting interactions and platform activity.\n'
              '• Social Graph Data: A record of interactions between users based on voting behavior.',
        ),
        _buildSubSection(
          '2.3 Device Permissions',
          'The Application requests the following device permissions:\n'
              '• Camera Access: To allow you to take a photo directly for your profile picture.\n'
              '• Photo Gallery / Storage Access: To allow you to upload an existing photo from your device.\n\n'
              'These permissions are only used for the stated purpose (profile photo upload) and are not used for background data collection.',
        ),
        _buildSection(
          '3. How We Use Your Information',
          'We use the information we collect for the following purposes:\n'
              '• To create, manage, and authenticate your user account.\n'
              '• To display your profile to other users within the Platform.\n'
              '• To calculate and display your Recognition Score and Leaderboard ranking.\n'
              '• To operate the time-locked monthly reveal feature.\n'
              '• To allow you to explore other profiles and use the search function.\n'
              '• To enforce our Terms of Service and moderate content.\n'
              '• To respond to support inquiries and communicate platform updates.\n'
              '• To improve the Platform\'s features, performance, and user experience.\n'
              '• To deliver admin broadcasts and campus announcements.',
        ),
        _buildSection(
          '4. Legal Basis for Processing',
          'We process your personal data on the following legal bases:\n'
              '• Contractual Necessity: Processing is necessary to perform our contract with you (i.e., to provide the Platform\'s services as described in our Terms).\n'
              '• Legitimate Interests: We process behavioral and interaction data based on our legitimate interests in operating and improving the Platform.\n'
              '• Consent: Where required, we rely on your explicit consent (e.g., camera/gallery permissions). You may withdraw consent at any time, though this may affect Platform functionality.',
        ),
        _buildSection('5. Data Sharing & Third Parties', ''),
        _buildSubSection(
          '5.1 Backend Infrastructure',
          'MainChar currently uses Supabase as its backend-as-a-service provider for database management and cloud storage. Your data is stored on Supabase\'s servers. Supabase is bound by its own privacy policies and data protection commitments. We do not currently use any other third-party analytics, advertising, or tracking services.',
        ),
        _buildSubSection(
          '5.2 No Sale of Data',
          'We do not sell, rent, or trade your personal information to any third party for commercial purposes.',
        ),
        _buildSubSection(
          '5.3 Legal Disclosures',
          'We may disclose your information if required to do so by law, or in response to a valid legal request by public authorities (e.g., a court order or law enforcement request).',
        ),
        _buildSubSection(
          '5.4 Business Transfers',
          'In the event that MainChar is acquired, merged, or undergoes a business transition, your personal data may be transferred as part of that transaction. We will notify you via in-app notification or email before your data is transferred and becomes subject to a different privacy policy.',
        ),
        _buildSection(
          '6. Public Information & Leaderboards',
          'Please be aware that the following information is PUBLIC and visible to all registered users of the Platform:\n'
              '• Your username / display name.\n'
              '• Your profile photo.\n'
              '• Your bio and vibe tags.\n'
              '• Your Recognition Score and Leaderboard ranking.\n\n'
              'Do not include sensitive personal information in your bio or any publicly visible profile field.',
        ),
        _buildSection('7. Data Retention', ''),
        _buildSubSection(
          '7.1 Active Accounts',
          'We retain your personal data for as long as your account is active and for as long as is necessary to provide you with the Platform\'s services.',
        ),
        _buildSubSection(
          '7.2 Account Deletion',
          'Upon requesting account deletion, we will:\n'
              '• Permanently delete your profile information: email address, username, profile photo, bio, and vibe tags.\n'
              '• Anonymize (not delete) your historical voting/swipe data. This means your votes will be retained in an anonymized form to preserve the integrity of other users\' Recognition Scores and Leaderboard rankings, but the data will no longer be linked to your identity.\n\n'
              'Account deletion requests can be submitted to demowork@gmail.com. We will process requests within a reasonable timeframe.',
        ),
        _buildSubSection(
          '7.3 Inactive Accounts',
          'We reserve the right to delete or anonymize accounts that have been inactive for an extended period. We will make reasonable efforts to notify you before doing so.',
        ),
        _buildSection(
          '8. Security',
          'We take the security of your personal information seriously and implement reasonable technical and organizational measures to protect it from unauthorized access, alteration, disclosure, or destruction. These include:\n'
              '• Secure authentication managed through Supabase.\n'
              '• Encrypted data transmission using HTTPS/TLS protocols.\n'
              '• Restricted access to production databases.\n\n'
              'However, no method of transmission over the Internet or method of electronic storage is 100% secure. We cannot guarantee absolute security of your data. In the event of a data breach that is likely to affect your rights, we will notify affected users in a timely manner.',
        ),
        _buildSection(
          '9. Your Rights',
          'Subject to applicable law, you have the following rights regarding your personal data:\n'
              '• Right of Access: You may request a copy of the personal data we hold about you.\n'
              '• Right to Rectification: You may request that we correct any inaccurate or incomplete data we hold about you.\n'
              '• Right to Erasure: You may request the deletion of your personal data (subject to our data retention practices described in Section 7).\n'
              '• Right to Restriction: You may request that we restrict the processing of your data in certain circumstances.\n'
              '• Right to Object: You may object to the processing of your data based on legitimate interests.\n'
              '• Right to Data Portability: You may request your data in a structured, commonly used format.\n\n'
              'To exercise any of these rights, please contact us at demowork@gmail.com.',
        ),
        _buildSection(
          '10. Children\'s Privacy',
          'MainChar is not intended for users under the age of 18. We do not knowingly collect personal information from minors. If you believe a minor has created an account on MainChar, please contact us immediately at demowork@gmail.com and we will take prompt action to delete the account and associated data.',
        ),
        _buildSection(
          '11. Device Permissions & Camera/Gallery',
          'The Platform requests access to your device camera and photo gallery solely for the purpose of uploading a profile picture. We do not use these permissions to access your photos in the background, collect metadata from images, or scan your gallery. You can revoke these permissions at any time through your device settings; however, doing so will prevent you from updating your profile photo.',
        ),
        _buildSection(
          '12. Changes to This Privacy Policy',
          'We may update this Privacy Policy from time to time to reflect changes in our practices or applicable law. We will notify you of material changes via in-app notification or by sending an email to the address associated with your account. Your continued use of the Platform following the posting of changes constitutes your acceptance of the revised policy.',
        ),
        _buildSection(
          '13. Contact Us',
          'If you have any questions, concerns, or requests regarding this Privacy Policy, or wish to exercise your data rights, please contact:\n\n'
              'Email: demowork@gmail.com\n'
              'Platform: MainChar (Demo Version)\n'
              'Jurisdiction: Punjab, Pakistan',
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            'IMPORTANT DISCLAIMER',
            style: AppTextStyles.label(
              12,
              color: Colors.redAccent,
              weight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This document is a DEMO DRAFT prepared for development purposes only. It is NOT legally reviewed or finalized. Before publishing MainChar publicly or submitting to any App Store, this document must be reviewed and approved by a qualified legal professional.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(
              14,
              color: AppColors.onSurfaceVariant,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildPartTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        title,
        style: AppTextStyles.label(
          14,
          color: AppColors.primary,
          weight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headline(20, color: AppColors.secondary),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              content,
              style: AppTextStyles.body(
                15,
                color: AppColors.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headline(16, weight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.body(14, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ).withBlur(100),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withOpacity(0.03),
            ),
          ).withBlur(100),
        ),
      ],
    );
  }
}

extension _BlurExtension on Widget {
  Widget withBlur(double sigma) => ImageFiltered(
    imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    child: this,
  );
}
