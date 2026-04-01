-- ============================================================
-- Création de la catégorie "Santé mentale" si elle n'existe pas
-- ============================================================
INSERT INTO category (name)
SELECT 'Santé mentale'
WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'Santé mentale');

-- ============================================================
-- Article 1 : Je me sens déprimé.e, dois-je m'inquiéter ?
-- ============================================================
INSERT INTO article_sante (title, description, content, publish_date, active, category_id)
VALUES (
  $$Je me sens déprimé.e, dois-je m'inquiéter ?$$,

  $$Fatigue, manque de motivation, tristesse… Comment distinguer une déprime passagère d'une dépression et quand consulter ?$$,

  $$<p class="article-sources">Dossier constitué avec : Ministère de la Santé et de la Prévention, Santé publique France, Psycom, Haute Autorité de Santé (HAS), PsyLab, World Health Organization (WHO).</p>

<div class="article-intro">
  <p>Fatigue ? Manque de motivation ? Difficulté à se concentrer ? Sommeil perturbé ? Tristesse ?</p>
  <p>Il peut s'agir d'une <strong>déprime</strong> ou bien d'une <strong>dépression</strong>.</p>
  <p>La première est un mal-être passager ; la seconde est une maladie qui nécessite une prise en charge médicale et psychothérapeutique.</p>
</div>

<h2>Le moral, un état en perpétuelle évolution</h2>
<p>La déprime est un mal-être passager qui fait partie de la vie ordinaire. Elle survient à l'occasion de difficultés, d'événements ou même sans raison apparente, voire juste de manière saisonnière.</p>
<p>En revanche, la dépression est une maladie. En 2017, la dépression a concerné près de 10 % des Français. Les populations les plus touchées sont les personnes de moins de 45 ans, les femmes, les chômeurs et les personnes inactives, les personnes veuves ou divorcées, ou les personnes déclarant de faibles revenus. À noter également : 8 % des personnes en emploi ont connu un épisode dépressif en 2017.</p>
<p>La dépression s'explique par divers facteurs psychologiques et liés à l'environnement social ou familial.</p>
<p>Certains facteurs interviennent très en amont ; ils « préparent le terrain ». Par exemple, le risque d'être touché par la dépression serait accru par le fait de vivre des événements traumatisants ou des conflits parentaux importants pendant la petite enfance.</p>
<p>D'autres facteurs interviennent juste avant la dépression, ils la « déclenchent » : mort d'un être cher, naissance d'un enfant, séparation, conflit familial, annonce d'une maladie grave, perte de son emploi, harcèlement à l'école ou au travail, etc.</p>
<p>Certains psychiatres conçoivent la dépression comme une profonde fatigue psychique, en particulier chez les personnes qui luttent depuis des années contre les diverses formes d'anxiété (anxiété généralisée, phobies, troubles paniques ou troubles obsessionnels compulsifs — TOC) ou contre les effets d'une mauvaise estime d'eux-mêmes.</p>
<p>Certains symptômes de la déprime et de la dépression sont identiques : fatigue, perte de concentration, troubles du sommeil, tristesse par exemple. Mais ceux de la déprime sont plus modérés et tendent à disparaître spontanément avec le temps et les activités sociales.</p>
<p>Dans le cas d'une dépression, ces symptômes se manifestent toute la journée et presque tous les jours, durant au moins deux semaines, et ils ne sont pas influencés par les circonstances.</p>
<p>D'autres symptômes peuvent venir s'y ajouter : perte ou gain de poids, troubles somatiques (maux de ventre ou de dos, par exemple), désespoir, voire désir d'en finir avec la vie. La personne touchée a un sentiment d'inutilité et d'impuissance, avec des idées morbides, voire suicidaires.</p>
<div class="article-warning">
  <p>Le suicide est le risque principal lié à la dépression. Il peut être prévenu par un traitement adapté de la maladie.</p>
</div>

<h2>À qui en parler ?</h2>
<p>Rester isolé sans parler de son état dépressif ne fait qu'aggraver la situation. Dire ce que l'on ressent quand on va mal, cela fait partie d'un processus naturel qui permet d'aller mieux. Il est donc primordial d'oser en parler à une personne de confiance. Cela peut être un proche, son médecin généraliste, un spécialiste de la santé psychique (psychologue, psychiatre), une association spécialisée, dans le cadre d'un groupe de parole, etc.</p>
<p>On peut également le faire de manière anonyme par l'intermédiaire d'un chat sur internet, d'une application mobile, ou d'une ligne d'écoute dédiée aux troubles psychiques.</p>
<div class="article-callout">
  <p>En cas de pensée suicidaire, parlez-en à un professionnel de santé ou à une ligne d'écoute. <strong>En cas d'urgence, appelez le 15.</strong></p>
</div>

<h2>Qui consulter ?</h2>
<p>La dépression est une maladie qui se soigne. Un traitement est nécessaire car la volonté seule ne suffit pas pour agir sur une maladie aussi complexe. Psychothérapie et/ou médicaments : il existe aujourd'hui des traitements efficaces, souvent complémentaires, adaptés à chaque personne et à l'intensité de la maladie.</p>
<div class="article-cards">
  <div class="article-card">
    <h3>Le psychiatre</h3>
    <p>Médecin spécialisé ayant reçu, après des études de médecine, un enseignement supplémentaire de quatre ans sur les maladies psychiques. En tant que médecin, il peut prescrire des médicaments en complément du soutien psychologique.</p>
  </div>
  <div class="article-card">
    <h3>Le psychologue</h3>
    <p>Professionnel ayant effectué cinq années de psychologie à l'université. Formé à l'écoute, il peut utiliser différents types de psychothérapies.</p>
  </div>
</div>

<h2>Les remboursements</h2>
<p>L'Assurance maladie prend en charge les soins, médicaments et psychothérapies dans certaines conditions :</p>
<ul>
  <li>Les consultations de médecin généraliste ou de psychiatre en cabinet privé sont remboursées selon les conditions du parcours de soins coordonnés (accès direct pour les personnes de 16 à 25 ans, adressage par le médecin traitant après 25 ans).</li>
  <li>Les consultations chez un psychologue sont remboursées uniquement si elles se déroulent dans un établissement public (centre médico-psychologique, hôpital de jour, centre d'accueil et de crise, par exemple).</li>
</ul>
<div class="article-highlight">
  <h3>Dispositif Mon Soutien Psy</h3>
  <p>Mon soutien psy propose jusqu'à <strong>12 séances</strong> d'accompagnement psychologique chez un psychologue partenaire. La séance coûte 50 €, remboursée à 60 % par l'Assurance Maladie. Ce dispositif s'adresse à toute personne dès 3 ans qui se sent angoissée, déprimée ou en souffrance psychique légère à modérée.</p>
</div>

<h2>Prendre soin de soi accélère la guérison</h2>
<p>Entretenir des liens sociaux est essentiel lorsqu'on souffre d'un état dépressif. Ce n'est pas forcément simple car la dépression incite à se replier sur soi et à se considérer comme « indigne » ou « incapable » d'avoir des relations satisfaisantes. Il est donc essentiel de profiter des périodes de rémission pour voir ses amis, sa famille, ses collègues, et participer à des activités caritatives, culturelles, sportives, artistiques.</p>
<p>Pratiquer régulièrement certaines activités physiques (marche rapide, vélo, natation) contribue à réduire les symptômes des dépressions légères à modérées. La pratique en groupe ou en club associe les bienfaits de l'activité physique à ceux de l'échange avec d'autres personnes.</p>
<p>Se relaxer grâce à différentes techniques (sophrologie, méditation, yoga) peut réduire les tensions du corps ainsi que la « rumination » et les idées noires. Pour être efficaces, ces approches nécessitent un temps d'apprentissage (de préférence avec un professionnel) et une pratique régulière.</p>$$,

  '2025-01-01',
  true,
  (SELECT id FROM category WHERE name = 'Santé mentale')
);

-- ============================================================
-- Article 2 : L'activité physique, une alliée pour notre santé mentale
-- ============================================================
INSERT INTO article_sante (title, description, content, publish_date, active, category_id)
VALUES (
  $$L'activité physique, une alliée pour notre santé mentale$$,

  $$Bouger régulièrement a un effet protecteur pour la santé mentale : moins de stress, meilleur sommeil, humeur améliorée. Découvrez pourquoi et comment intégrer l'activité physique dans votre quotidien.$$,

  $$<div class="article-intro">
  <p>Bouger régulièrement, dans la vie de tous les jours, a un effet protecteur pour la santé mentale. Cela permet d'améliorer notre état de bien-être et limiter l'apparition de certains troubles psychiques. C'est également positif pour nos fonctions cognitives comme notre mémoire ou notre capacité de concentration.</p>
</div>

<h2>Les bienfaits de l'activité physique</h2>
<p>L'activité physique permet de :</p>
<ul>
  <li>Lutter contre le stress ;</li>
  <li>Améliorer la qualité de notre sommeil ;</li>
  <li>Mieux gérer nos émotions ;</li>
  <li>Améliorer notre humeur ;</li>
  <li>Réduire l'anxiété ;</li>
  <li>Réduire des symptômes de la dépression.</li>
</ul>
<p>L'activité physique peut aussi nous aider à prendre confiance en nous. Quand on arrive à avoir une pratique régulière, on peut en retirer de la fierté, être content de nous en constatant : <strong>« J'y arrive ! »</strong></p>

<h2>L'activité physique, ce n'est pas que le sport</h2>
<p>Le sport fait partie de l'activité physique mais l'activité physique, c'est bien plus que ça. Cela peut être un loisir comme danser, nager, se promener, jardiner ou bricoler. On peut aussi faire de l'activité physique dans les tâches du quotidien, en prenant les escaliers plutôt que l'ascenseur, en faisant du ménage, ou encore en se déplaçant à pied ou en vélo pour faire ses courses ou pour aller travailler.</p>

<h2>Pourquoi l'activité physique améliore la santé mentale ?</h2>
<p>Trois types de facteurs expliquent pourquoi l'activité physique est bénéfique pour la santé mentale.</p>
<div class="article-cards">
  <div class="article-card">
    <h3>Facteurs biologiques</h3>
    <p>Quand on fait de l'exercice physique, notre corps produit de la <strong>sérotonine</strong>, connue pour son effet antidépresseur et son action sur la régulation de l'humeur. Il produit aussi des <strong>endorphines</strong> qui réduisent la douleur et procurent une sensation de bonheur.</p>
  </div>
  <div class="article-card">
    <h3>Facteurs psychologiques</h3>
    <p>On renforce notre estime de soi. Lorsqu'on s'active physiquement, cela peut avoir pour effet de mettre sur pause les pensées négatives liées au stress, à la dépression ou à l'anxiété.</p>
  </div>
  <div class="article-card">
    <h3>Facteurs sociaux</h3>
    <p>Pratiquer une activité physique avec d'autres personnes — sport collectif, marche entre collègues — apporte un double bénéfice : l'effet positif de l'activité elle-même, plus l'effet positif du lien social et du sentiment d'appartenance à un groupe.</p>
  </div>
</div>

<h2>Je bouge combien de temps pour améliorer ma santé mentale ?</h2>
<p>Bonne nouvelle : on peut déjà ressentir des effets positifs après une <strong>vingtaine de minutes</strong> d'activité physique modérée. On appelle « activité physique modérée » toute activité qui nous essouffle légèrement, par exemple une marche rapide.</p>
<p>Pour en tirer des bénéfices qui durent, il est recommandé de faire chaque jour au moins <strong>30 minutes</strong> d'activité physique modérée à élevée.</p>

<h2>Et si je n'arrive pas à me motiver ?</h2>
<p>Voici quelques conseils pour vous aider à vous y mettre :</p>
<ul>
  <li><strong>Trouvez votre propre motivation :</strong> vous faire plaisir, vous sentir fier de vous, vous amuser, vous détendre, prendre soin de votre corps, vous lancer un défi…</li>
  <li><strong>Commencez en douceur :</strong> y aller progressivement, d'abord 1 fois par semaine, puis 2… Sans vous comparer à des athlètes ou à des personnes qui pratiquent depuis des années.</li>
  <li><strong>Essayez différentes activités</strong> à différents moments de la journée (le matin avant de partir travailler, le soir en rentrant).</li>
  <li><strong>Trouvez votre rythme</strong> pour pouvoir être le plus régulier possible.</li>
</ul>
<div class="article-callout">
  <p><strong>Point d'attention :</strong> Si l'activité physique peut contribuer à améliorer la santé mentale, elle ne remplace pas une prise en charge adaptée en cas de troubles psychiques. N'hésitez pas à prendre l'avis d'un professionnel de santé (médecin généraliste, psychiatre, psychologue).</p>
</div>

<div class="article-highlight">
  <h3>L'essentiel à retenir</h3>
  <ul>
    <li>Pratiquer une activité physique régulière est bénéfique à la santé mentale.</li>
    <li>On peut ressentir des effets positifs dès 20 minutes d'activité modérée.</li>
    <li>Pour des bénéfices durables : au moins 30 minutes par jour.</li>
    <li>L'activité physique, ce n'est pas que le sport : marche, vélo, ménage, jardinage… tout compte !</li>
    <li>L'idée, c'est d'être actif, de bouger plusieurs fois par jour et de réduire le temps passé assis.</li>
  </ul>
</div>$$,

  '2025-01-15',
  true,
  (SELECT id FROM category WHERE name = 'Santé mentale')
);

-- ============================================================
-- Article 3 : Sommeil et santé mentale, des liens forts
-- ============================================================
INSERT INTO article_sante (title, description, content, publish_date, active, category_id)
VALUES (
  $$Sommeil et santé mentale, des liens forts$$,

  $$Notre sommeil a des effets sur notre santé mentale, et notre santé mentale a des effets sur notre sommeil. En prenant soin de l'un, on prend soin de l'autre.$$,

  $$<div class="article-intro">
  <p>Notre sommeil a des effets sur notre santé mentale. Et notre santé mentale a des effets sur notre sommeil. En prenant soin de notre sommeil, on prend aussi soin de notre santé mentale.</p>
</div>

<h2>Quelles sont les relations entre sommeil et santé mentale ?</h2>
<p>Tout le monde en a fait l'expérience : une mauvaise nuit de sommeil nous rend plus irritable, moins motivé. On supporte moins les réflexions des autres, on a tendance à s'énerver plus facilement… À cause du manque de sommeil, on peut aussi avoir des difficultés de mémoire ou de concentration.</p>
<p>Quand ils durent, les problèmes de sommeil peuvent aussi favoriser l'apparition de troubles psychiques comme la dépression ou les troubles anxieux. À l'inverse, un trouble psychique peut perturber notre sommeil.</p>

<h2>Sommeil et cortisol</h2>
<p>Le <strong>cortisol</strong> est l'hormone du stress. Sa production est liée à notre rythme de sommeil. Normalement, elle est à son maximum le matin — ce qui nous aide à nous réveiller — puis diminue petit à petit au cours de la journée.</p>
<p>Un mauvais sommeil peut dérégler cette production. Et quand elle est dérèglée, cela peut provoquer à son tour un mauvais sommeil et une augmentation du stress. C'est un cercle vicieux.</p>

<h2>Des besoins de sommeil différents</h2>
<p>Il existe des « gros » et des « petits » dormeurs. La durée moyenne d'une nuit de sommeil varie entre <strong>7 et 9 heures</strong>. La durée idéale, c'est celle qui nous permet de nous sentir reposé au réveil et en forme dans la journée.</p>
<p>Les besoins en sommeil changent aussi au cours de la vie : pendant l'enfance et l'adolescence, on a besoin de plus de sommeil qu'à l'âge adulte. En vieillissant, on peut avoir besoin de moins de sommeil.</p>

<h2>Quand on dort mal…</h2>
<p>Passer une mauvaise nuit, cela peut être :</p>
<div class="article-cards">
  <div class="article-card">
    <h3>L'insomnie</h3>
    <p>De grandes difficultés à s'endormir ou à se rendormir après un réveil, des réveils multiples dans la nuit ou très tôt le matin.</p>
  </div>
  <div class="article-card">
    <h3>L'hypersomnie</h3>
    <p>Dormir beaucoup sans se sentir reposé pour autant.</p>
  </div>
</div>
<p>Un mauvais sommeil peut s'expliquer de nombreuses manières :</p>
<ul>
  <li><strong>Raisons physiologiques :</strong> apnée du sommeil, douleurs, bouffées de chaleur, etc.</li>
  <li><strong>Raisons psychologiques :</strong> préoccupations liées au travail, conflit familial, déménagement, rupture, deuil, difficultés financières, annonce d'une maladie, etc.</li>
</ul>

<h2>Quand le sommeil se complique</h2>
<p>Si les difficultés de sommeil reviennent plusieurs nuits par semaine, mieux vaut s'en occuper sans tarder pour éviter qu'elles ne s'installent. Repérer ce qui nous empêche de bien dormir est une première étape pour trouver une solution.</p>
<p>Tenir un <strong>« journal du sommeil »</strong> permet de mieux connaître son sommeil : on y note ses habitudes de vie (activité physique, usage des écrans, alimentation…) et leurs effets sur la qualité du sommeil, afin d'identifier ce qu'on peut essayer de modifier.</p>

<h2>Que faire si je dors mal ?</h2>
<p>Enchaîner plusieurs mauvaises nuits peut entraîner un cercle vicieux : plus on dort mal, plus on est fatigué, plus on a du mal à dormir. Voici quelques conseils pratiques pour en sortir.</p>
<p><strong>Couchez-vous et levez-vous à peu près à la même heure tous les jours</strong>, semaine comme week-end.</p>

<div class="article-highlight">
  <h3>Avant de vous coucher</h3>
  <ul>
    <li>Éteignez les écrans (télé, tablette, smartphone) une heure avant de vous coucher. Mettez le téléphone en mode avion.</li>
    <li>Évitez les activités stimulantes (sport, travail) juste avant de vous coucher.</li>
    <li>Limitez les repas trop riches le soir — mais évitez aussi de vous coucher en ayant faim ou soif.</li>
    <li>Aménagez un espace calme et sombre. Si besoin, bouchons d'oreilles et masque sur les yeux. Température idéale : 18 °C en hiver.</li>
  </ul>
</div>

<div class="article-highlight">
  <h3>En journée</h3>
  <ul>
    <li>Pratiquez une activité physique régulière, de préférence le matin.</li>
    <li>Sortez profiter de la lumière du jour, surtout le matin.</li>
    <li>Réduisez les excitants (thé, café) après 14 heures.</li>
    <li>Faites une sieste de 15 à 20 minutes si possible.</li>
  </ul>
</div>$$,

  '2025-02-01',
  true,
  7
);

-- ============================================================
-- Article 4 : Parler quand ça ne va pas, c'est déjà prendre soin de soi
-- ============================================================
INSERT INTO article_sante (title, description, content, publish_date, active, category_id)
VALUES (
  $$Parler quand ça ne va pas, c'est déjà prendre soin de soi$$,

  $$Quand on va mal, on a parfois tendance à garder ses difficultés pour soi. Pourtant, parler peut être un bon début pour aller mieux.$$,

  $$<div class="article-intro">
  <p>Quelle que soit la cause de notre souffrance — les soucis du quotidien qui s'accumulent, l'annonce d'une maladie grave, un deuil, une rupture… — il est important de pouvoir en parler à un proche ou à un professionnel de l'écoute.</p>
</div>

<h2>Parler quand ça ne va pas, ça veut dire quoi ?</h2>
<p>Quand on sent qu'on ne va pas bien, parler de ses difficultés ou de ses ressentis permet de :</p>
<ul>
  <li><strong>Prendre du recul :</strong> raconter ce qu'on vit, mettre des mots sur ses émotions, peut nous permettre d'y voir plus clair.</li>
  <li><strong>Réduire l'anxiété et le stress :</strong> se sentir écouté, sans être jugé, peut nous apaiser.</li>
  <li><strong>Trouver de nouvelles solutions :</strong> quand quelqu'un d'autre se penche sur notre situation, cela peut faire apparaître des pistes auxquelles on n'avait pas pensé.</li>
</ul>
<p>Parler ne va pas tout résoudre d'un coup, mais c'est souvent une première étape pour commencer à surmonter ses difficultés et, si besoin, pour demander de l'aide auprès d'un professionnel de santé mentale.</p>

<h2>Faire le premier pas pour se faire aider</h2>
<p>Parfois, on se fait de fausses idées sur le fait de parler de ses difficultés ou de demander de l'aide. C'est ce qui peut rendre cette étape encore plus difficile. Par exemple :</p>
<ul>
  <li>On a peur d'être jugé ;</li>
  <li>On a peur de passer pour quelqu'un de faible ;</li>
  <li>On a l'impression de déranger, d'embêter les gens avec ses problèmes.</li>
</ul>
<p>Mais on a tous une santé mentale : on rencontre tous des difficultés et on a tous besoin de soutien à certains moments de notre vie. <strong>Plus on agit tôt, moins on laisse les difficultés s'installer.</strong></p>
<p>Pour franchir ce pas, on peut réfléchir à qui on aimerait se confier et au type d'aide que l'on souhaite : partager ce qu'on vit avec un proche, être accompagné par un professionnel de santé mentale, ou obtenir des informations sur des structures d'aide.</p>

<h2>Vers qui me tourner ?</h2>
<div class="article-cards">
  <div class="article-card">
    <h3>Un proche</h3>
    <p>Un ami, un membre de votre famille, un collègue ou une personne avec qui vous partagez une activité.</p>
  </div>
  <div class="article-card">
    <h3>Une ligne d'écoute</h3>
    <p>Si vous n'êtes pas à l'aise pour en parler à votre entourage, les lignes d'écoute proposent une écoute bienveillante et sans jugement.</p>
  </div>
  <div class="article-card">
    <h3>Une association</h3>
    <p>Certaines proposent des groupes de parole pour échanger avec des personnes qui vivent la même situation (deuil, violences, trouble psychique…). Renseignez-vous auprès de votre mairie.</p>
  </div>
  <div class="article-card">
    <h3>Un professionnel de santé</h3>
    <p>Votre médecin traitant peut vous conseiller. Vous pouvez aussi vous adresser directement à un psychiatre ou un psychologue. Via le dispositif Mon Soutien Psy, jusqu'à 12 séances sont prises en charge par l'Assurance Maladie.</p>
  </div>
</div>
<p>Dans tous les cas, il est important de <strong>ne pas rester seul avec votre souffrance.</strong></p>

<div class="article-warning">
  <h3 style="color:#991b1b; margin-bottom:0.5rem;">Idées suicidaires — urgences</h3>
  <p>En cas d'idées suicidaires, pour vous ou pour un proche, contactez le <strong>3114</strong> — numéro national de prévention du suicide.</p>
  <p style="margin-bottom:0">En cas d'urgence, contactez le <strong>SAMU au 15</strong>. Ces numéros sont accessibles 24h/24, 7j/7, gratuitement et en toute confidentialité.</p>
</div>

<div class="article-highlight">
  <h3>L'essentiel à retenir</h3>
  <ul>
    <li>Parler est une première étape importante en cas de mal-être.</li>
    <li>On a tous besoin de soutien à certains moments de notre vie.</li>
    <li>Il existe différentes formes de soutien adaptées à chaque situation.</li>
    <li>Plus on agit tôt, moins on laisse les difficultés s'installer.</li>
  </ul>
</div>$$,

  '2025-02-15',
  true,
  6
);
