import 'contact_basics.dart';
import 'cv_vault.dart';
import 'education.dart';
import 'experience.dart';
import 'experience_bullet.dart';
import 'hobby_item.dart';
import 'profile_link.dart';
import 'skill.dart';
import 'skill_category.dart';
import 'year_month.dart';

/// A wholly fictional persona, structured to mirror the shape of a real
/// reference CV used during design (labelled AND unlabelled work bullets,
/// two skill categories, two education entries, hobbies, a references
/// note) so it exercises every branch of the `classic_serif` template.
///
/// Used by the "Load example CV" button and as the deterministic fixture
/// behind golden tests. Deliberately NOT real personal data — this repo
/// is public, and anything committed here is permanently in git history.
CvVault buildExampleVault() => CvVault(
  schemaVersion: 1,
  updatedAt: DateTime.utc(2026, 1, 1),
  basics: const ContactBasics(
    fullName: 'Jordan Ellery',
    headline: 'Senior Software Engineer',
    email: 'jordan.ellery@example.com',
    phone: '+44 7700 900123',
    location: 'Manchester',
    summary:
        'Results-driven Senior Software Engineer with a track record of '
        'delivering secure, high-performance web platforms, combining '
        'technical depth with cross-functional stakeholder management.',
    links: [
      ProfileLink(
        id: 'link-linkedin',
        label: 'LinkedIn',
        url: 'linkedin.com/in/jordanellery',
      ),
    ],
  ),
  experiences: [
    Experience(
      id: 'exp-1',
      role: 'Senior Software Engineer',
      company: 'Northbridge Financial',
      location: 'Manchester',
      start: const YearMonth(year: 2023, month: 3),
      isCurrent: true,
      bullets: const [
        ExperienceBullet(
          id: 'exp-1-b1',
          label: 'Platform migration',
          text:
              'Led a phased migration of the core ledger service, '
              'cutting transaction processing latency by 60%.',
        ),
        ExperienceBullet(
          id: 'exp-1-b2',
          label: 'Security uplift',
          text:
              'Introduced automated dependency scanning into CI, '
              'resolving 80% of known vulnerabilities pre-release.',
        ),
        ExperienceBullet(
          id: 'exp-1-b3',
          label: 'Mentorship',
          text:
              'Established a rotating tech-lead programme, growing '
              'three engineers into senior roles within a year.',
        ),
      ],
    ),
    Experience(
      id: 'exp-2',
      role: 'Software Engineer',
      company: 'Riverside Digital',
      location: 'Leeds',
      start: const YearMonth(year: 2020, month: 6),
      end: const YearMonth(year: 2023, month: 2),
      bullets: const [
        ExperienceBullet(
          id: 'exp-2-b1',
          text:
              'Built a multi-tenant reporting platform used by over '
              '40 enterprise clients to track compliance metrics.',
        ),
        ExperienceBullet(
          id: 'exp-2-b2',
          label: 'Performance',
          text:
              'Refactored a slow ORM query path, reducing page load '
              'times from 4s to under 400ms.',
        ),
        ExperienceBullet(
          id: 'exp-2-b3',
          label: 'API design',
          text:
              'Designed the public REST API adopted as the '
              'integration standard across three product teams.',
        ),
      ],
    ),
    Experience(
      id: 'exp-3',
      role: 'Junior Developer',
      company: 'Fernway Software',
      location: 'Leeds',
      start: const YearMonth(year: 2019, month: 1),
      end: const YearMonth(year: 2020, month: 5),
      bullets: const [
        ExperienceBullet(
          id: 'exp-3-b1',
          label: 'Foundational work',
          text:
              'Contributed to the initial release of a booking '
              'system now used by 200+ small businesses.',
        ),
        ExperienceBullet(
          id: 'exp-3-b2',
          label: 'Testing',
          text:
              'Introduced the team’s first automated test suite, '
              'covering 70% of critical booking flows.',
        ),
      ],
    ),
  ],
  skillCategories: const [
    SkillCategory(
      id: 'skills-lang',
      name: 'Languages & Frameworks',
      skills: [
        Skill(id: 'skill-dart', label: 'Dart (Flutter)'),
        Skill(id: 'skill-ts', label: 'TypeScript (React, Node.js)'),
        Skill(id: 'skill-py', label: 'Python (FastAPI)'),
      ],
    ),
    SkillCategory(
      id: 'skills-cloud',
      name: 'Cloud & DevOps',
      skills: [
        Skill(id: 'skill-aws', label: 'AWS'),
        Skill(id: 'skill-gcp', label: 'GCP'),
        Skill(id: 'skill-cicd', label: 'CI/CD Pipeline Automation'),
      ],
    ),
  ],
  education: const [
    Education(
      id: 'edu-1',
      qualification: 'BSc Computer Science',
      institution: 'University of Leeds',
      year: 2018,
      grade: 'First Class Honours',
    ),
    Education(
      id: 'edu-2',
      qualification: 'HND Software Development',
      institution: 'Leeds City College',
      year: 2015,
    ),
  ],
  hobbies: const [
    HobbyItem(id: 'hobby-1', text: 'Amateur woodworking'),
    HobbyItem(id: 'hobby-2', text: 'Training for a first half marathon'),
  ],
  referencesNote: 'Available on request.',
);
