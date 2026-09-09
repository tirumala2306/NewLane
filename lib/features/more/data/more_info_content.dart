class MoreInfoContent {
  const MoreInfoContent({
    required this.appBarTitle,
    required this.heading,
    required this.sections,
  });

  final String appBarTitle;
  final String heading;
  final List<MoreInfoSection> sections;

  static const MoreInfoContent privacy = MoreInfoContent(
    appBarTitle: 'PRIVACY POLICY',
    heading: 'Privacy Policy',
    sections: <MoreInfoSection>[
      MoreInfoSection(
        paragraphs: <String>[
          'At New Lane, we value your privacy and are committed to protecting your personal information.',
          'When you use the app, we may collect information including your name, email address, phone number, profile photo, office location, and account activity. This information is used to provide access to the app, personalize your experience, improve our services, send important notifications, and maintain account security.',
          'We do not sell your personal information. Information may be shared only with trusted service providers that help us operate the platform.',
          'You may request to update or delete your account information at any time by contacting our support team.',
          'If this Privacy Policy is updated, the latest version will always be available within the app.',
        ],
        footer: 'Support Email: gabrielr@marsblue.co',
      ),
    ],
  );

  static const MoreInfoContent security = MoreInfoContent(
    appBarTitle: 'SECURITY',
    heading: 'Security',
    sections: <MoreInfoSection>[
      MoreInfoSection(
        paragraphs: <String>[
          'Your account security is important to us.',
          'To help protect your information, New Lane uses secure authentication and encrypted connections whenever possible.',
          'Users are responsible for keeping their login credentials private and should never share their password with others.',
          'If you believe your account has been compromised or notice any suspicious activity, please contact our support team immediately.',
        ],
        footer: 'Contact: gabrielr@marsblue.co',
      ),
    ],
  );

  static const MoreInfoContent helpSupport = MoreInfoContent(
    appBarTitle: 'HELP & SUPPORT',
    heading: 'Help & Support',
    sections: <MoreInfoSection>[
      MoreInfoSection(
        paragraphs: <String>[
          "Need assistance? We're here to help.",
          'Contact us for:',
        ],
        bullets: <String>[
          'Account or login issues',
          'Profile updates',
          'Office information',
          'App technical support',
          'Training and event questions',
          'General inquiries',
        ],
        footer: 'Email: gabrielr@marsblue.co',
      ),
    ],
  );

  static const MoreInfoContent terms = MoreInfoContent(
    appBarTitle: 'TERMS & CONDITIONS',
    heading: 'Terms & Conditions',
    sections: <MoreInfoSection>[
      MoreInfoSection(
        paragraphs: <String>[
          'By using the New Lane app, you agree to the following terms:',
        ],
        bullets: <String>[
          'Provide accurate and up-to-date account information.',
          'Keep your login credentials secure.',
          'Use the app only for lawful and professional purposes.',
          'Do not misuse, copy, or distribute any content within the app without authorization.',
          'Respect company policies and other users of the platform.',
        ],
      ),
      MoreInfoSection(
        paragraphs: <String>[
          'New Lane reserves the right to suspend or terminate accounts that violate these terms or misuse the platform.',
          'Features, services, and app content may be updated or modified at any time without prior notice.',
          'Continued use of the app indicates your acceptance of these Terms & Conditions.',
        ],
        footer:
            'For questions regarding these terms, please contact gabrielr@marsblue.co.',
      ),
    ],
  );

  static const MoreInfoContent about = MoreInfoContent(
    appBarTitle: 'ABOUT APP',
    heading: 'About New Lane',
    sections: <MoreInfoSection>[
      MoreInfoSection(
        paragraphs: <String>[
          'New Lane is a modern real estate brokerage platform designed to keep agents connected, informed, and engaged.',
          'Through the app, agents can:',
        ],
        bullets: <String>[
          'Manage their professional profile',
          'View office information',
          'Receive company announcements',
          'Stay updated on events and training',
          'Access brokerage resources',
          'Receive important notifications',
          'Stay connected with the New Lane community',
        ],
      ),
      MoreInfoSection(
        paragraphs: <String>[
          'Our mission is to provide agents with the tools, communication, and resources they need to grow their business while staying connected with the New Lane community.',
        ],
        footer: 'Version: 1.0.0\n\nSupport: gabrielr@marsblue.co',
      ),
    ],
  );
}

class MoreInfoSection {
  const MoreInfoSection({
    this.paragraphs = const <String>[],
    this.bullets = const <String>[],
    this.footer,
  });

  final List<String> paragraphs;
  final List<String> bullets;
  final String? footer;
}
