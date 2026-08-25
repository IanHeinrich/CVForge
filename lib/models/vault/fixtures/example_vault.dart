import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';

/// A fictional persona, modeled on a real senior engineer's career shape
/// (same domain — FinTech, security, testing infra — same skill stack and
/// seniority arc) so it exercises every branch of the `compact` template,
/// but every employer, exact metric, and client engagement below is
/// invented. The [projects] list is the one deliberate exception: it
/// points at real, public repositories the author of this app actually
/// maintains (this project among them), so "Load example CV" showcases
/// genuine portfolio work rather than fictional demo links.
///
/// Used by the "Load example CV" button and as the deterministic fixture
/// behind golden tests. Deliberately NOT real personal/career data — this
/// repo is public, and anything committed here is permanently in git
/// history, so nothing outside [projects] should be traceable back to a
/// specific real person via employer name, exact metric, or personal
/// identifying detail.
CvVault buildExampleVault() => CvVault(
  schemaVersion: 1,
  updatedAt: DateTime.utc(2026, 1, 1),
  basics: const ContactBasics(
    fullName: 'Morgan Vance',
    headline: 'Senior Software Engineer',
    email: 'morgan.vance@example.com',
    phone: '+44 7700 900198',
    location: 'London',
    summary:
        'Results-driven Senior Software Engineer with a strong track '
        'record of architecting secure, high-performance FinTech '
        'infrastructure, combining deep technical delivery with '
        'cross-functional leadership and stakeholder management.',
    links: [
      ProfileLink(
        id: 'link-linkedin',
        label: 'LinkedIn',
        url: 'linkedin.com/in/morganvance',
      ),
    ],
  ),
  experiences: [
    Experience(
      id: 'exp-1',
      role: 'Senior Software Engineer',
      company: 'Alderney Financial',
      location: 'London',
      start: const YearMonth(year: 2023, month: 6),
      isCurrent: true,
      bullets: const [
        CvBullet(
          id: 'exp-1-b1',
          text:
              'Partnered with the Security team to bake automated '
              'vulnerability scanning into the release pipeline, catching '
              'the large majority of issues before they reached '
              'production.',
        ),
        CvBullet(
          id: 'exp-1-b2',
          text:
              'Built core card-payment infrastructure optimized for '
              'low-latency processing at scale.',
        ),
        CvBullet(
          id: 'exp-1-b3',
          text:
              'Led the design and delivery of a digital wallet '
              'integration, measurably lifting card activation.',
        ),
        CvBullet(
          id: 'exp-1-b4',
          text:
              'Drove a transaction schema migration that cut transaction '
              'load times dramatically, unlocking support for new '
              'transaction types.',
        ),
        CvBullet(
          id: 'exp-1-b5',
          text:
              'Built automated regulatory reporting, cutting manual '
              'finance reporting effort by most of its previous overhead.',
        ),
        CvBullet(
          id: 'exp-1-b6',
          text:
              'Led adoption of a cloud device farm for end-to-end testing '
              '— vendor selection, budget sign-off, framework '
              'integration, and team upskilling — reducing critical '
              'frontend incidents.',
        ),
        CvBullet(
          id: 'exp-1-b7',
          text:
              'Built an AI-driven pull request analysis workflow that '
              'selects and runs only the relevant end-to-end tests, '
              'cutting pipeline time while holding coverage steady.',
        ),
      ],
    ),
    Experience(
      id: 'exp-2',
      role: 'Software Engineer II',
      company: 'Alderney Financial',
      location: 'London',
      start: const YearMonth(year: 2021, month: 9),
      end: const YearMonth(year: 2023, month: 5),
      bullets: const [
        CvBullet(
          id: 'exp-2-b1',
          text:
              'One of the first engineers on the team; helped architect '
              'the transactional banking engine from the ground up.',
        ),
        CvBullet(
          id: 'exp-2-b2',
          text:
              'Led the build of a customer due-diligence platform, '
              'automating a large share of manual KYC/KYB checks and '
              'cutting onboarding time from days to minutes.',
        ),
        CvBullet(
          id: 'exp-2-b3',
          text:
              'Created internal training that brought the engineering '
              'team to full compliance with card-industry security '
              'standards.',
        ),
        CvBullet(
          id: 'exp-2-b4',
          text:
              'Founded and led a cross-team security guild, running '
              'workshops on secure data handling and secure-by-default '
              'design.',
        ),
      ],
    ),
    Experience(
      id: 'exp-3',
      role: 'Full Stack Engineer',
      company: 'Solventra Health Tech',
      location: 'London',
      start: const YearMonth(year: 2020, month: 8),
      end: const YearMonth(year: 2021, month: 8),
      bullets: const [
        CvBullet(
          id: 'exp-3-b1',
          text:
              'Designed a scalable multi-tenant architecture, enabling '
              'enterprise clients to securely manage isolated '
              'sub-organizations and federated permissions.',
        ),
        CvBullet(
          id: 'exp-3-b2',
          text:
              'Led a security audit and remediation plan for highly '
              'sensitive health data, tightening encryption and access '
              'controls.',
        ),
        CvBullet(
          id: 'exp-3-b3',
          text:
              'Refactored a slow ORM query path, cutting a critical '
              'page\'s load time from several seconds to well under half '
              'a second.',
        ),
      ],
    ),
    Experience(
      id: 'exp-4',
      role: 'Contract Software Engineer',
      company: 'Independent — various clients',
      location: 'Edinburgh',
      start: const YearMonth(year: 2019, month: 2),
      end: const YearMonth(year: 2021, month: 7),
      bullets: const [
        CvBullet(
          id: 'exp-4-b1',
          text:
              'Architected a cross-platform Flutter app with a '
              'serverless cloud backend, working directly with enterprise '
              'clients to shape product requirements.',
        ),
        CvBullet(
          id: 'exp-4-b2',
          text:
              'Built a Flutter app with a custom rendering and '
              'real-time cost-estimation engine, automating a sales '
              'quoting pipeline for architecture firms.',
        ),
      ],
    ),
    Experience(
      id: 'exp-5',
      role: 'Full Stack Engineer (Part-time)',
      company: 'Meridian Facilities',
      location: 'Edinburgh',
      start: const YearMonth(year: 2018, month: 9),
      end: const YearMonth(year: 2019, month: 2),
      bullets: const [
        CvBullet(
          id: 'exp-5-b1',
          text:
              'Built a companion Flutter app for a visitor and goods '
              'management system, backed by a cloud stack, to streamline '
              'site operations.',
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
        Skill(id: 'skill-ts', label: 'TypeScript/JavaScript (React, Node.js)'),
        Skill(id: 'skill-py', label: 'Python (FastAPI)'),
        Skill(id: 'skill-db', label: 'Relational & Non-relational Databases'),
      ],
    ),
    SkillCategory(
      id: 'skills-cloud',
      name: 'Cloud, DevOps & AI',
      skills: [
        Skill(id: 'skill-aws', label: 'AWS'),
        Skill(id: 'skill-gcp', label: 'GCP'),
        Skill(id: 'skill-cicd', label: 'CI/CD Pipeline Automation'),
        Skill(id: 'skill-ai', label: 'AI-Assisted Tooling'),
      ],
    ),
    SkillCategory(
      id: 'skills-arch',
      name: 'Architecture',
      skills: [
        Skill(id: 'skill-secarch', label: 'Security Architecture'),
        Skill(id: 'skill-pcidss', label: 'PCI-DSS Compliance'),
        Skill(id: 'skill-multitenant', label: 'Multi-tenant Systems'),
      ],
    ),
  ],
  projects: const [
    Project(
      id: 'proj-1',
      title: 'cv-forge',
      link: 'github.com/IanHeinrich/cv-forge',
      bullets: [
        CvBullet(
          id: 'proj-1-b1',
          text:
              'A privacy-first, client-side CV builder — nothing leaves '
              'the browser.',
        ),
      ],
    ),
    Project(
      id: 'proj-2',
      title: 'vid2grid',
      link: 'github.com/IanHeinrich/vid2grid',
      bullets: [
        CvBullet(
          id: 'proj-2-b1',
          text:
              'Parses a video into optimally-packed grids of timestamped '
              'frames for feeding into AI vision models, entirely '
              'client-side — nothing is uploaded.',
        ),
      ],
    ),
    Project(
      id: 'proj-3',
      title: 'total-war-mod-patcher',
      link: 'github.com/IanHeinrich/total-war-mod-patcher',
      bullets: [
        CvBullet(
          id: 'proj-3-b1',
          text:
              'A CLI + GUI tool that automates the extract/edit/repack '
              'cycle for Total War mod files, wrapping RPFM\'s headless '
              'server so table edits can happen in a real IDE.',
        ),
      ],
    ),
    Project(
      id: 'proj-4',
      title: 'serverpod_logger_plus',
      link: 'github.com/IanHeinrich/serverpod_logger_plus',
      bullets: [
        CvBullet(
          id: 'proj-4-b1',
          text:
              'A structured-logging package for Serverpod that '
              'dual-routes every log call to Serverpod Insights and a '
              'pluggable JSON writer for GCP/Datadog/Elastic and others.',
        ),
      ],
    ),
  ],
  education: const [
    Education(
      id: 'edu-1',
      qualification: 'BSc Computing Science',
      institution: 'University of Sheffield',
      year: 2022,
    ),
    Education(
      id: 'edu-2',
      qualification: 'HND Software Development',
      institution: 'Sheffield City College',
      year: 2017,
    ),
  ],
  hobbies: const [
    HobbyItem(id: 'hobby-1', text: 'Weekend rock climbing'),
    HobbyItem(id: 'hobby-2', text: 'Training for a first marathon'),
  ],
  publications: const [
    Publication(
      id: 'pub-1',
      title:
          'Eventually consistent ledgers: practical patterns for '
          'real-time reconciliation at scale',
      citation: 'Vance, M. (2024). Alderney Engineering Notes, 4(2), 8–15.',
      link: 'doi.org/10.1234/example-ledger-recon',
      bullets: [
        CvBullet(
          id: 'pub-1-b1',
          text:
              'Cited internally as the reference pattern for two '
              'subsequent reconciliation services.',
        ),
      ],
    ),
    Publication(
      id: 'pub-2',
      title:
          'Selective end-to-end testing: cutting CI time without '
          'cutting coverage',
      citation: 'Vance, M. (2025). Proceedings of the Regional DevOps Meetup.',
    ),
  ],
  referencesNote: 'Available on request.',
);
