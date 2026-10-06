import '../domain/lesson.dart';

/// Les leçons de l'application.
///
/// Le contenu est écrit dans le code : il est disponible hors connexion dès
/// l'installation, sans rien télécharger.
const List<Lesson> lessonCatalog = [
  Lesson(
    id: 'etf-ou-action',
    title: 'ETF ou action\u00A0: quelle différence\u00A0?',
    category: LessonCategory.basics,
    minutes: 5,
    blocks: [
      LessonParagraph(
        'Une action est une petite part d’une seule entreprise. Si '
        'l’entreprise réussit, l’action prend de la valeur\u00A0; si elle va mal, '
        'l’action baisse, parfois fortement.',
      ),
      LessonParagraph(
        'Un ETF est un fonds coté en bourse qui suit un indice, par exemple '
        'le S&P 500 ou le MSCI World. En achetant une part d’ETF, vous '
        'détenez un petit morceau de toutes les entreprises de l’indice.',
      ),
      LessonComparison(
        columns: ['Action', 'ETF'],
        rows: [
          ComparisonRow('Entreprises', ['Une seule', 'Des dizaines à des milliers']),
          ComparisonRow('Risque', ['Dépend d’une société', 'Réparti entre toutes']),
          ComparisonRow('Frais', ['Courtage', 'Courtage et frais annuels']),
          ComparisonRow('Suivi', ['Choisir et surveiller', 'Suit l’indice tout seul']),
        ],
      ),
      LessonNote(
        'Un ETF n’est pas sans risque\u00A0: il suit le marché, à la hausse comme '
        'à la baisse.',
      ),
    ],
    keyPoints: [
      'Une action, c’est une entreprise\u00A0; un ETF, c’est un panier d’entreprises.',
      'Un ETF permet de diversifier avec un petit montant.',
      'Un ETF peut baisser quand le marché baisse.',
    ],
    quiz: [
      QuizQuestion(
        question: 'Un ETF qui suit le MSCI World contient…',
        options: [
          'une seule grande entreprise américaine',
          'de nombreuses entreprises de pays développés',
          'uniquement des obligations',
        ],
        correctIndex: 1,
        explanation:
            'Le MSCI World regroupe de nombreuses entreprises de pays '
            'développés\u00A0: l’ETF qui le suit les détient toutes.',
      ),
      QuizQuestion(
        question: 'Vrai ou faux\u00A0: un ETF ne peut pas perdre de valeur.',
        options: ['Vrai', 'Faux'],
        correctIndex: 1,
        explanation:
            'Faux. Un ETF suit son indice\u00A0: si le marché baisse, sa valeur '
            'baisse aussi.',
      ),
    ],
  ),
  Lesson(
    id: 'interets-composes',
    title: 'Les intérêts composés',
    category: LessonCategory.basics,
    minutes: 3,
    blocks: [
      LessonParagraph(
        'Avec les intérêts composés, les gains d’une année s’ajoutent au '
        'capital et produisent à leur tour des gains l’année suivante. C’est '
        'l’effet «\u00A0boule de neige\u00A0».',
      ),
      LessonNote(
        '1\u00A0000\u00A0€ placés à 5\u00A0% par an pendant 10 ans deviennent environ '
        '1\u00A0629\u00A0€. Sans réinvestir les intérêts, on n’aurait que 1\u00A0500\u00A0€.',
      ),
      LessonParagraph(
        'L’écart est faible au début et grandit avec le temps\u00A0: la durée '
        'compte autant que le montant. Le rendement, lui, n’est jamais '
        'garanti sur un placement en bourse.',
      ),
    ],
    keyPoints: [
      'Les intérêts produisent eux-mêmes des intérêts.',
      'Plus la durée est longue, plus l’effet est fort.',
      'Commencer tôt compte souvent plus que commencer gros.',
    ],
    quiz: [
      QuizQuestion(
        question: 'Qu’est-ce qui renforce le plus l’effet des intérêts composés\u00A0?',
        options: ['La durée du placement', 'Le jour de la semaine', 'Le nom de la banque'],
        correctIndex: 0,
        explanation:
            'Chaque année supplémentaire fait travailler les gains des années '
            'précédentes.',
      ),
      QuizQuestion(
        question: '1\u00A0000\u00A0€ à 5\u00A0% par an, intérêts réinvestis\u00A0: après 10 ans, on a environ…',
        options: ['1\u00A0050\u00A0€', '1\u00A0500\u00A0€', '1\u00A0629\u00A0€'],
        correctIndex: 2,
        explanation: '1\u00A0000 × 1,05 puissance 10 ≈ 1\u00A0629\u00A0€.',
      ),
    ],
  ),
  Lesson(
    id: 'diversifier',
    title: 'Pourquoi diversifier\u00A0?',
    category: LessonCategory.basics,
    minutes: 4,
    blocks: [
      LessonParagraph(
        'Diversifier, c’est répartir son argent entre plusieurs entreprises, '
        'secteurs, pays ou types de placements, pour ne pas dépendre d’un '
        'seul.',
      ),
      LessonParagraph(
        'Si une entreprise sur cent fait faillite, un portefeuille qui en '
        'contient cent perd peu. Un portefeuille qui ne contenait qu’elle '
        'perd tout.',
      ),
      LessonBullets([
        'Entre entreprises\u00A0: ne pas tout miser sur une seule action.',
        'Entre secteurs\u00A0: technologie, santé, énergie…',
        'Entre zones\u00A0: États-Unis, Europe, pays émergents.',
        'Entre placements\u00A0: actions, obligations, épargne disponible.',
      ]),
      LessonNote(
        'La diversification réduit le risque lié à une entreprise, pas le '
        'risque d’une baisse générale des marchés.',
      ),
    ],
    keyPoints: [
      'Ne pas dépendre d’une seule entreprise ni d’un seul secteur.',
      'Un ETF large est déjà diversifié.',
      'Diversifier réduit le risque, sans le supprimer.',
    ],
    quiz: [
      QuizQuestion(
        question: 'Quel portefeuille est le plus diversifié\u00A0?',
        options: [
          'Trois actions du même secteur',
          'Un ETF qui suit un indice mondial',
          'Une seule action très connue',
        ],
        correctIndex: 1,
        explanation:
            'Un indice mondial couvre de nombreux pays, secteurs et '
            'entreprises.',
      ),
    ],
  ),
  Lesson(
    id: 'enveloppes',
    title: 'PEA, PEL, compte-titres',
    category: LessonCategory.envelopes,
    minutes: 6,
    blocks: [
      LessonParagraph(
        'Une enveloppe, c’est le «\u00A0contenant\u00A0» de votre épargne. Elle fixe ce '
        'que vous pouvez y mettre, les plafonds et la façon dont les gains '
        'sont imposés.',
      ),
      LessonComparison(
        columns: ['PEA', 'PEL', 'Compte-titres'],
        rows: [
          ComparisonRow('On y met', [
            'Actions européennes et ETF éligibles',
            'De l’argent, rémunéré à taux fixe',
            'Tous les titres',
          ]),
          ComparisonRow('Plafond', ['150\u00A0000\u00A0€ de versements', '61\u00A0200\u00A0€', 'Aucun']),
          ComparisonRow('Risque', ['Perte possible', 'Capital garanti', 'Perte possible']),
          ComparisonRow('Atout', [
            'Fiscalité allégée après 5 ans',
            'Taux connu à l’ouverture',
            'Aucune contrainte',
          ]),
        ],
      ),
      LessonParagraph(
        'Le PEA (plan d’épargne en actions) est pensé pour un placement long. '
        'Le PEL (plan d’épargne logement) prépare plutôt un projet '
        'immobilier. Le compte-titres ordinaire sert quand on veut des titres '
        'que le PEA n’accepte pas.',
      ),
      LessonNote(
        'Les règles fiscales changent régulièrement\u00A0: vérifiez-les sur '
        'service-public.fr avant d’ouvrir une enveloppe.',
      ),
    ],
    keyPoints: [
      'L’enveloppe ne dit pas dans quoi vous investissez, mais dans quel cadre.',
      'PEA\u00A0: placement long en actions européennes et ETF éligibles.',
      'PEL\u00A0: épargne sans risque, tournée vers un projet immobilier.',
      'Compte-titres\u00A0: tous les titres, sans avantage fiscal particulier.',
    ],
    quiz: [
      QuizQuestion(
        question: 'Laquelle de ces enveloppes garantit le capital versé\u00A0?',
        options: ['Le PEA', 'Le PEL', 'Le compte-titres'],
        correctIndex: 1,
        explanation:
            'Le PEL est un produit d’épargne à capital garanti. PEA et '
            'compte-titres contiennent des titres dont la valeur varie.',
      ),
      QuizQuestion(
        question: 'Laquelle n’a aucun plafond de versement\u00A0?',
        options: ['Le PEA', 'Le PEL', 'Le compte-titres'],
        correctIndex: 2,
        explanation: 'Le compte-titres ordinaire n’a ni plafond ni contrainte.',
      ),
    ],
  ),
  Lesson(
    id: 'risque-volatilite',
    title: 'Risque, volatilité et baisses',
    category: LessonCategory.risk,
    minutes: 5,
    blocks: [
      LessonParagraph(
        'La volatilité répond à la question\u00A0: «\u00A0le prix de ce placement '
        'varie-t-il beaucoup\u00A0?\u00A0». Plus les variations sont fortes d’une '
        'période à l’autre, plus le placement est volatil.',
      ),
      LessonParagraph(
        'La pire baisse (maximum drawdown) mesure la plus forte chute entre '
        'un sommet et le point bas qui le suit.',
      ),
      LessonNote(
        'Un cours passe de 100 à 125, puis tombe à 90. La pire baisse est de '
        '(90 − 125) ÷ 125 = −28\u00A0%.',
      ),
      LessonParagraph(
        'Un rendement espéré plus élevé va en général avec des variations '
        'plus fortes. La bonne question n’est pas «\u00A0combien puis-je gagner\u00A0?\u00A0» '
        'mais «\u00A0quelle baisse suis-je capable de supporter sans vendre\u00A0?\u00A0».',
      ),
    ],
    keyPoints: [
      'Volatilité\u00A0: l’ampleur des variations de prix.',
      'Pire baisse\u00A0: la plus forte chute depuis un sommet.',
      'Rendement espéré et risque vont ensemble.',
    ],
    quiz: [
      QuizQuestion(
        question: 'Un cours passe de 200 à 150. La baisse est de…',
        options: ['−25\u00A0%', '−33\u00A0%', '−50\u00A0%'],
        correctIndex: 0,
        explanation: '(150 − 200) ÷ 200 = −25\u00A0%.',
      ),
      QuizQuestion(
        question: 'Un placement très volatil est un placement…',
        options: [
          'dont le prix varie beaucoup',
          'qui rapporte toujours plus',
          'dont le capital est garanti',
        ],
        correctIndex: 0,
        explanation:
            'La volatilité décrit l’ampleur des variations, pas le gain final.',
      ),
    ],
  ),
  Lesson(
    id: 'horizon',
    title: 'L’horizon de placement',
    category: LessonCategory.risk,
    minutes: 3,
    blocks: [
      LessonParagraph(
        'L’horizon de placement, c’est la durée pendant laquelle vous pouvez '
        'laisser votre argent investi sans en avoir besoin.',
      ),
      LessonBullets([
        'Moins de 2 ans\u00A0: l’argent doit rester disponible et sans risque.',
        'De 2 à 8 ans\u00A0: une partie seulement peut être exposée aux marchés.',
        'Plus de 8 ans\u00A0: on a le temps de traverser des baisses temporaires.',
      ]),
      LessonNote(
        'Avant d’investir, gardez une épargne de précaution disponible pour '
        'les imprévus\u00A0: elle évite de devoir vendre au mauvais moment.',
      ),
    ],
    keyPoints: [
      'Plus l’horizon est long, plus on peut accepter de variations.',
      'L’argent dont on a besoin bientôt ne va pas en bourse.',
      'L’épargne de précaution passe avant l’investissement.',
    ],
    quiz: [
      QuizQuestion(
        question: 'Vous aurez besoin de cet argent dans un an. Le plus adapté est…',
        options: [
          'un placement disponible et sans risque',
          'une seule action prometteuse',
          'un ETF très volatil',
        ],
        correctIndex: 0,
        explanation:
            'Sur un an, une baisse des marchés n’aurait pas le temps de se '
            'rattraper.',
      ),
    ],
  ),
  Lesson(
    id: 'frais-inflation',
    title: 'Frais et inflation',
    category: LessonCategory.risk,
    minutes: 4,
    blocks: [
      LessonParagraph(
        'L’inflation est la hausse générale des prix. Avec elle, une même '
        'somme permet d’acheter moins de choses au fil des années.',
      ),
      LessonNote(
        'Avec 2\u00A0% d’inflation par an, 100\u00A0€ d’aujourd’hui n’achètent plus, '
        'dans 10 ans, que l’équivalent d’environ 82\u00A0€.',
      ),
      LessonParagraph(
        'Les frais réduisent le rendement chaque année, et leur effet '
        's’accumule lui aussi.',
      ),
      LessonNote(
        '10\u00A0000\u00A0€ pendant 20 ans\u00A0: environ 26\u00A0500\u00A0€ à 5\u00A0% par an, mais '
        'environ 21\u00A0900\u00A0€ si 1 point de frais ramène le rendement à 4\u00A0%.',
      ),
    ],
    keyPoints: [
      'L’inflation réduit ce que l’argent permet d’acheter.',
      'Un rendement se juge après frais et après inflation.',
      'Un point de frais par an pèse lourd sur vingt ans.',
    ],
    quiz: [
      QuizQuestion(
        question: 'Votre placement rapporte 3\u00A0% et l’inflation est de 3\u00A0%. Votre pouvoir d’achat…',
        options: ['augmente', 'reste à peu près stable', 'double'],
        correctIndex: 1,
        explanation:
            'Le gain compense tout juste la hausse des prix\u00A0: vous ne pouvez '
            'pas acheter plus qu’avant.',
      ),
    ],
  ),
];
