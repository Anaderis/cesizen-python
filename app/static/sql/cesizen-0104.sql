--
-- PostgreSQL database dump
--

\restrict fYNBOJLCJClsGdH3F6Lujappma8BEmnhSzPwet30WaANvN4PqntM9ykOaIOcjye

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-06-08 21:06:43

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 16465)
-- Name: activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity (
    id integer CONSTRAINT activite_id_not_null NOT NULL,
    title character varying(255) CONSTRAINT activite_titre_not_null NOT NULL,
    description text,
    url character varying(500),
    active boolean DEFAULT true,
    category_id integer CONSTRAINT activite_categorie_id_not_null NOT NULL,
    format_id integer CONSTRAINT activite_format_id_not_null NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    duration character varying(20),
    photo character varying(255)
);


ALTER TABLE public.activity OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16464)
-- Name: activite_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.activite_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activite_id_seq OWNER TO postgres;

--
-- TOC entry 5103 (class 0 OID 0)
-- Dependencies: 229
-- Name: activite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.activite_id_seq OWNED BY public.activity.id;


--
-- TOC entry 228 (class 1259 OID 16446)
-- Name: article_sante; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.article_sante (
    id integer NOT NULL,
    title character varying(255) CONSTRAINT article_sante_titre_not_null NOT NULL,
    description text,
    publish_date date,
    active boolean DEFAULT true,
    category_id integer CONSTRAINT article_sante_categorie_id_not_null NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    content text,
    photo character varying(255)
);


ALTER TABLE public.article_sante OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16445)
-- Name: article_sante_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.article_sante_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.article_sante_id_seq OWNER TO postgres;

--
-- TOC entry 5104 (class 0 OID 0)
-- Dependencies: 227
-- Name: article_sante_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.article_sante_id_seq OWNED BY public.article_sante.id;


--
-- TOC entry 222 (class 1259 OID 16401)
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    id integer CONSTRAINT categorie_id_not_null NOT NULL,
    name character varying(100) CONSTRAINT categorie_libelle_not_null NOT NULL
);


ALTER TABLE public.category OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16400)
-- Name: categorie_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorie_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorie_id_seq OWNER TO postgres;

--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 221
-- Name: categorie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorie_id_seq OWNED BY public.category.id;


--
-- TOC entry 231 (class 1259 OID 16489)
-- Name: favorites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favorites (
    user_id integer CONSTRAINT favori_utilisateur_id_not_null NOT NULL,
    activity_id integer CONSTRAINT favori_activite_id_not_null NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.favorites OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16412)
-- Name: format; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.format (
    id integer NOT NULL,
    type character varying(50) CONSTRAINT format_libelle_not_null NOT NULL
);


ALTER TABLE public.format OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16411)
-- Name: format_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.format_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.format_id_seq OWNER TO postgres;

--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 223
-- Name: format_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.format_id_seq OWNED BY public.format.id;


--
-- TOC entry 233 (class 1259 OID 16508)
-- Name: log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log (
    id integer NOT NULL,
    user_id integer CONSTRAINT log_utilisateur_id_not_null NOT NULL,
    action character varying(100) NOT NULL,
    description text,
    date_action timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.log OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16507)
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_id_seq OWNER TO postgres;

--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 232
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;


--
-- TOC entry 220 (class 1259 OID 16390)
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    id integer NOT NULL,
    type character varying(100) CONSTRAINT role_libelle_not_null NOT NULL
);


ALTER TABLE public.role OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16389)
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.role_id_seq OWNER TO postgres;

--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 219
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;


--
-- TOC entry 226 (class 1259 OID 16423)
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id integer CONSTRAINT utilisateur_id_not_null NOT NULL,
    name character varying(100) CONSTRAINT utilisateur_nom_not_null NOT NULL,
    surname character varying(100) CONSTRAINT utilisateur_prenom_not_null NOT NULL,
    email character varying(150) CONSTRAINT utilisateur_email_not_null NOT NULL,
    password character varying(255) CONSTRAINT utilisateur_password_not_null NOT NULL,
    phone character varying(20),
    photo character varying(255),
    description text,
    role_id integer CONSTRAINT utilisateur_role_id_not_null NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16422)
-- Name: utilisateur_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.utilisateur_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.utilisateur_id_seq OWNER TO postgres;

--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 225
-- Name: utilisateur_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.utilisateur_id_seq OWNED BY public."user".id;


--
-- TOC entry 4899 (class 2604 OID 16468)
-- Name: activity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity ALTER COLUMN id SET DEFAULT nextval('public.activite_id_seq'::regclass);


--
-- TOC entry 4896 (class 2604 OID 16449)
-- Name: article_sante id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_sante ALTER COLUMN id SET DEFAULT nextval('public.article_sante_id_seq'::regclass);


--
-- TOC entry 4891 (class 2604 OID 16404)
-- Name: category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.categorie_id_seq'::regclass);


--
-- TOC entry 4892 (class 2604 OID 16415)
-- Name: format id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.format ALTER COLUMN id SET DEFAULT nextval('public.format_id_seq'::regclass);


--
-- TOC entry 4903 (class 2604 OID 16511)
-- Name: log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- TOC entry 4890 (class 2604 OID 16393)
-- Name: role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- TOC entry 4893 (class 2604 OID 16426)
-- Name: user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.utilisateur_id_seq'::regclass);


--
-- TOC entry 5094 (class 0 OID 16465)
-- Dependencies: 230
-- Data for Name: activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity (id, title, description, url, active, category_id, format_id, created_at, duration, photo) FROM stdin;
8	Mieux vivre avec la dépression	La dépression est une maladie dont l'origine est plurifactorielle. Son développement résulterait d'une interaction entre des facteurs biologiques, génétiques, psychologiques et environnementaux.	/static/activities/pdfs/depression.pdf	t	4	1	2026-04-02 13:47:41.640416	90 minutes	activity-depression.jpg
9	Programme MAALSI	Programme de cours	\N	f	8	1	2026-04-14 09:30:06.110834	50min	\N
3	Pilates pour le dos	Marjorie Jamin, professeur de pilates, vous propose une séance de 30 min pour renforcer son dos.	https://youtu.be/JSIrLK0cE5s?si=2YK1p1GDz9-Pry0d	t	8	3	2026-03-28 13:27:41.439801	30min.	\N
4	Ça vous change la vie - Reconnaître les signes de la dépression	Véronique Mounier vous explique comment reconnaître les signes de la dépression, chez vous ou chez vos proches.	https://www.youtube.com/watch?v=q-Y0H5DlQ_E	t	3	3	2026-04-02 13:26:27.501664	2min	\N
5	Sophrologie pour éviter le Burn-out	Delphine Bourdet, sophrologue à Paris, vous propose d'évacuer le stress, de vous affirmer davantage et de reprendre confiance en vous. Pour éviter le burn-out ou en sortir, vous avez besoin d'un rdv quotidien avec vous-même.	https://www.youtube.com/watch?v=LvNGc2uXZMk	t	4	3	2026-04-02 13:29:59.006902	14min	\N
6	Méditation World of Warcraft : Découverte d'Azeroth	Découvrez quelques endroits d'Azeroth en toute tranquillité ou presque ! À écouter en position assise ou bien allongée. Bonne méditation !	https://www.youtube.com/watch?v=58IWfwfW43w	t	9	3	2026-04-02 13:35:19.439021	20min	\N
10	Test cours	cesi	\N	f	8	1	2026-04-14 10:08:14.740953	56	\N
11	Test numéro deux	test upload fichier	/static/activities/pdfs/2e45aced76cc45d8a8f453e817b82ff9.pdf	f	8	1	2026-04-14 11:09:07.141281	40	\N
12	La motivation au travail	En tant que manager,\ncomment entretenir et dynamiser\nla motivation au travail des équipes\nen faveur de la qualité du service public\nd’éducation ?	/static/activities/pdfs/6d96414d704f4338b4cb46aea4550b2f.pdf	t	5	1	2026-04-14 11:14:52.732514	60min	\N
7	Le syndrome d'épuisement professionnel ou burnout	Risques psychosociaux (RPS), stress, burnout… autant de mots qui circulent, amplifiés parfois par le porte-voix des médias, comme s'ils étaient la traduction d'un malaise ou d'un ressenti envers leur travail que des personnes ne savent pas toujours exprimer.	/static/activities/pdfs/burnout.pdf	t	4	1	2026-04-02 13:43:55.472044	90 minutes	activity-burnout.jpg
13	Test	test	/static/activities/pdfs/1891c052992645c1b597295b5632c603.pdf	f	2	1	2026-04-23 20:16:17.60616	\N	\N
14	Vidéo méditation	méditation	https://www.youtube.com/watch?v=SFxod1jWfMg&pp=ygUWZG9jdGlzc2ltbyByZXNwaXJhdGlvbg%3D%3D	f	8	3	2026-04-23 20:16:54.352804	\N	\N
15	test soutennace	soutenance	/static/activities/pdfs/ad09f7effc4b434ca2ac6bedf75ae06f.pdf	t	8	1	2026-04-24 10:12:50.147529	\N	\N
\.


--
-- TOC entry 5092 (class 0 OID 16446)
-- Dependencies: 228
-- Data for Name: article_sante; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.article_sante (id, title, description, publish_date, active, category_id, created_at, content, photo) FROM stdin;
4	Je me sens déprimé.e, dois-je m'inquiéter ?	Fatigue, manque de motivation, tristesse… Comment distinguer une déprime passagère d'une dépression et quand consulter ?	2025-01-01	t	11	2026-04-01 21:10:49.092111	<p class="article-sources">Dossier constitué avec : Ministère de la Santé et de la Prévention, Santé publique France, Psycom, Haute Autorité de Santé (HAS), PsyLab, World Health Organization (WHO).</p>\n\n<div class="article-intro">\n  <p>Fatigue ? Manque de motivation ? Difficulté à se concentrer ? Sommeil perturbé ? Tristesse ?</p>\n  <p>Il peut s'agir d'une <strong>déprime</strong> ou bien d'une <strong>dépression</strong>.</p>\n  <p>La première est un mal-être passager ; la seconde est une maladie qui nécessite une prise en charge médicale et psychothérapeutique.</p>\n</div>\n\n<h2>Le moral, un état en perpétuelle évolution</h2>\n<p>La déprime est un mal-être passager qui fait partie de la vie ordinaire. Elle survient à l'occasion de difficultés, d'événements ou même sans raison apparente, voire juste de manière saisonnière.</p>\n<p>En revanche, la dépression est une maladie. En 2017, la dépression a concerné près de 10 % des Français. Les populations les plus touchées sont les personnes de moins de 45 ans, les femmes, les chômeurs et les personnes inactives, les personnes veuves ou divorcées, ou les personnes déclarant de faibles revenus. À noter également : 8 % des personnes en emploi ont connu un épisode dépressif en 2017.</p>\n<p>La dépression s'explique par divers facteurs psychologiques et liés à l'environnement social ou familial.</p>\n<p>Certains facteurs interviennent très en amont ; ils « préparent le terrain ». Par exemple, le risque d'être touché par la dépression serait accru par le fait de vivre des événements traumatisants ou des conflits parentaux importants pendant la petite enfance.</p>\n<p>D'autres facteurs interviennent juste avant la dépression, ils la « déclenchent » : mort d'un être cher, naissance d'un enfant, séparation, conflit familial, annonce d'une maladie grave, perte de son emploi, harcèlement à l'école ou au travail, etc.</p>\n<p>Certains psychiatres conçoivent la dépression comme une profonde fatigue psychique, en particulier chez les personnes qui luttent depuis des années contre les diverses formes d'anxiété (anxiété généralisée, phobies, troubles paniques ou troubles obsessionnels compulsifs — TOC) ou contre les effets d'une mauvaise estime d'eux-mêmes.</p>\n<p>Certains symptômes de la déprime et de la dépression sont identiques : fatigue, perte de concentration, troubles du sommeil, tristesse par exemple. Mais ceux de la déprime sont plus modérés et tendent à disparaître spontanément avec le temps et les activités sociales.</p>\n<p>Dans le cas d'une dépression, ces symptômes se manifestent toute la journée et presque tous les jours, durant au moins deux semaines, et ils ne sont pas influencés par les circonstances.</p>\n<p>D'autres symptômes peuvent venir s'y ajouter : perte ou gain de poids, troubles somatiques (maux de ventre ou de dos, par exemple), désespoir, voire désir d'en finir avec la vie. La personne touchée a un sentiment d'inutilité et d'impuissance, avec des idées morbides, voire suicidaires.</p>\n<div class="article-warning">\n  <p>Le suicide est le risque principal lié à la dépression. Il peut être prévenu par un traitement adapté de la maladie.</p>\n</div>\n\n<h2>À qui en parler ?</h2>\n<p>Rester isolé sans parler de son état dépressif ne fait qu'aggraver la situation. Dire ce que l'on ressent quand on va mal, cela fait partie d'un processus naturel qui permet d'aller mieux. Il est donc primordial d'oser en parler à une personne de confiance. Cela peut être un proche, son médecin généraliste, un spécialiste de la santé psychique (psychologue, psychiatre), une association spécialisée, dans le cadre d'un groupe de parole, etc.</p>\n<p>On peut également le faire de manière anonyme par l'intermédiaire d'un chat sur internet, d'une application mobile, ou d'une ligne d'écoute dédiée aux troubles psychiques.</p>\n<div class="article-callout">\n  <p>En cas de pensée suicidaire, parlez-en à un professionnel de santé ou à une ligne d'écoute. <strong>En cas d'urgence, appelez le 15.</strong></p>\n</div>\n\n<h2>Qui consulter ?</h2>\n<p>La dépression est une maladie qui se soigne. Un traitement est nécessaire car la volonté seule ne suffit pas pour agir sur une maladie aussi complexe. Psychothérapie et/ou médicaments : il existe aujourd'hui des traitements efficaces, souvent complémentaires, adaptés à chaque personne et à l'intensité de la maladie.</p>\n<div class="article-cards">\n  <div class="article-card">\n    <h3>Le psychiatre</h3>\n    <p>Médecin spécialisé ayant reçu, après des études de médecine, un enseignement supplémentaire de quatre ans sur les maladies psychiques. En tant que médecin, il peut prescrire des médicaments en complément du soutien psychologique.</p>\n  </div>\n  <div class="article-card">\n    <h3>Le psychologue</h3>\n    <p>Professionnel ayant effectué cinq années de psychologie à l'université. Formé à l'écoute, il peut utiliser différents types de psychothérapies.</p>\n  </div>\n</div>\n\n<h2>Les remboursements</h2>\n<p>L'Assurance maladie prend en charge les soins, médicaments et psychothérapies dans certaines conditions :</p>\n<ul>\n  <li>Les consultations de médecin généraliste ou de psychiatre en cabinet privé sont remboursées selon les conditions du parcours de soins coordonnés (accès direct pour les personnes de 16 à 25 ans, adressage par le médecin traitant après 25 ans).</li>\n  <li>Les consultations chez un psychologue sont remboursées uniquement si elles se déroulent dans un établissement public (centre médico-psychologique, hôpital de jour, centre d'accueil et de crise, par exemple).</li>\n</ul>\n<div class="article-highlight">\n  <h3>Dispositif Mon Soutien Psy</h3>\n  <p>Mon soutien psy propose jusqu'à <strong>12 séances</strong> d'accompagnement psychologique chez un psychologue partenaire. La séance coûte 50 €, remboursée à 60 % par l'Assurance Maladie. Ce dispositif s'adresse à toute personne dès 3 ans qui se sent angoissée, déprimée ou en souffrance psychique légère à modérée.</p>\n</div>\n\n<h2>Prendre soin de soi accélère la guérison</h2>\n<p>Entretenir des liens sociaux est essentiel lorsqu'on souffre d'un état dépressif. Ce n'est pas forcément simple car la dépression incite à se replier sur soi et à se considérer comme « indigne » ou « incapable » d'avoir des relations satisfaisantes. Il est donc essentiel de profiter des périodes de rémission pour voir ses amis, sa famille, ses collègues, et participer à des activités caritatives, culturelles, sportives, artistiques.</p>\n<p>Pratiquer régulièrement certaines activités physiques (marche rapide, vélo, natation) contribue à réduire les symptômes des dépressions légères à modérées. La pratique en groupe ou en club associe les bienfaits de l'activité physique à ceux de l'échange avec d'autres personnes.</p>\n<p>Se relaxer grâce à différentes techniques (sophrologie, méditation, yoga) peut réduire les tensions du corps ainsi que la « rumination » et les idées noires. Pour être efficaces, ces approches nécessitent un temps d'apprentissage (de préférence avec un professionnel) et une pratique régulière.</p>	depression-article.jpg
5	L'activité physique, une alliée pour notre santé mentale	Bouger régulièrement a un effet protecteur pour la santé mentale : moins de stress, meilleur sommeil, humeur améliorée. Découvrez pourquoi et comment intégrer l'activité physique dans votre quotidien.	2025-01-15	t	11	2026-04-01 21:10:49.092111	<div class="article-intro">\n  <p>Bouger régulièrement, dans la vie de tous les jours, a un effet protecteur pour la santé mentale. Cela permet d'améliorer notre état de bien-être et limiter l'apparition de certains troubles psychiques. C'est également positif pour nos fonctions cognitives comme notre mémoire ou notre capacité de concentration.</p>\n</div>\n\n<h2>Les bienfaits de l'activité physique</h2>\n<p>L'activité physique permet de :</p>\n<ul>\n  <li>Lutter contre le stress ;</li>\n  <li>Améliorer la qualité de notre sommeil ;</li>\n  <li>Mieux gérer nos émotions ;</li>\n  <li>Améliorer notre humeur ;</li>\n  <li>Réduire l'anxiété ;</li>\n  <li>Réduire des symptômes de la dépression.</li>\n</ul>\n<p>L'activité physique peut aussi nous aider à prendre confiance en nous. Quand on arrive à avoir une pratique régulière, on peut en retirer de la fierté, être content de nous en constatant : <strong>« J'y arrive ! »</strong></p>\n\n<h2>L'activité physique, ce n'est pas que le sport</h2>\n<p>Le sport fait partie de l'activité physique mais l'activité physique, c'est bien plus que ça. Cela peut être un loisir comme danser, nager, se promener, jardiner ou bricoler. On peut aussi faire de l'activité physique dans les tâches du quotidien, en prenant les escaliers plutôt que l'ascenseur, en faisant du ménage, ou encore en se déplaçant à pied ou en vélo pour faire ses courses ou pour aller travailler.</p>\n\n<h2>Pourquoi l'activité physique améliore la santé mentale ?</h2>\n<p>Trois types de facteurs expliquent pourquoi l'activité physique est bénéfique pour la santé mentale.</p>\n<div class="article-cards">\n  <div class="article-card">\n    <h3>Facteurs biologiques</h3>\n    <p>Quand on fait de l'exercice physique, notre corps produit de la <strong>sérotonine</strong>, connue pour son effet antidépresseur et son action sur la régulation de l'humeur. Il produit aussi des <strong>endorphines</strong> qui réduisent la douleur et procurent une sensation de bonheur.</p>\n  </div>\n  <div class="article-card">\n    <h3>Facteurs psychologiques</h3>\n    <p>On renforce notre estime de soi. Lorsqu'on s'active physiquement, cela peut avoir pour effet de mettre sur pause les pensées négatives liées au stress, à la dépression ou à l'anxiété.</p>\n  </div>\n  <div class="article-card">\n    <h3>Facteurs sociaux</h3>\n    <p>Pratiquer une activité physique avec d'autres personnes — sport collectif, marche entre collègues — apporte un double bénéfice : l'effet positif de l'activité elle-même, plus l'effet positif du lien social et du sentiment d'appartenance à un groupe.</p>\n  </div>\n</div>\n\n<h2>Je bouge combien de temps pour améliorer ma santé mentale ?</h2>\n<p>Bonne nouvelle : on peut déjà ressentir des effets positifs après une <strong>vingtaine de minutes</strong> d'activité physique modérée. On appelle « activité physique modérée » toute activité qui nous essouffle légèrement, par exemple une marche rapide.</p>\n<p>Pour en tirer des bénéfices qui durent, il est recommandé de faire chaque jour au moins <strong>30 minutes</strong> d'activité physique modérée à élevée.</p>\n\n<h2>Et si je n'arrive pas à me motiver ?</h2>\n<p>Voici quelques conseils pour vous aider à vous y mettre :</p>\n<ul>\n  <li><strong>Trouvez votre propre motivation :</strong> vous faire plaisir, vous sentir fier de vous, vous amuser, vous détendre, prendre soin de votre corps, vous lancer un défi…</li>\n  <li><strong>Commencez en douceur :</strong> y aller progressivement, d'abord 1 fois par semaine, puis 2… Sans vous comparer à des athlètes ou à des personnes qui pratiquent depuis des années.</li>\n  <li><strong>Essayez différentes activités</strong> à différents moments de la journée (le matin avant de partir travailler, le soir en rentrant).</li>\n  <li><strong>Trouvez votre rythme</strong> pour pouvoir être le plus régulier possible.</li>\n</ul>\n<div class="article-callout">\n  <p><strong>Point d'attention :</strong> Si l'activité physique peut contribuer à améliorer la santé mentale, elle ne remplace pas une prise en charge adaptée en cas de troubles psychiques. N'hésitez pas à prendre l'avis d'un professionnel de santé (médecin généraliste, psychiatre, psychologue).</p>\n</div>\n\n<div class="article-highlight">\n  <h3>L'essentiel à retenir</h3>\n  <ul>\n    <li>Pratiquer une activité physique régulière est bénéfique à la santé mentale.</li>\n    <li>On peut ressentir des effets positifs dès 20 minutes d'activité modérée.</li>\n    <li>Pour des bénéfices durables : au moins 30 minutes par jour.</li>\n    <li>L'activité physique, ce n'est pas que le sport : marche, vélo, ménage, jardinage… tout compte !</li>\n    <li>L'idée, c'est d'être actif, de bouger plusieurs fois par jour et de réduire le temps passé assis.</li>\n  </ul>\n</div>	sport-article.jpg
6	Sommeil et santé mentale, des liens forts	Notre sommeil a des effets sur notre santé mentale, et notre santé mentale a des effets sur notre sommeil. En prenant soin de l'un, on prend soin de l'autre.	2025-02-01	t	7	2026-04-01 21:10:49.092111	<div class="article-intro">\n  <p>Notre sommeil a des effets sur notre santé mentale. Et notre santé mentale a des effets sur notre sommeil. En prenant soin de notre sommeil, on prend aussi soin de notre santé mentale.</p>\n</div>\n\n<h2>Quelles sont les relations entre sommeil et santé mentale ?</h2>\n<p>Tout le monde en a fait l'expérience : une mauvaise nuit de sommeil nous rend plus irritable, moins motivé. On supporte moins les réflexions des autres, on a tendance à s'énerver plus facilement… À cause du manque de sommeil, on peut aussi avoir des difficultés de mémoire ou de concentration.</p>\n<p>Quand ils durent, les problèmes de sommeil peuvent aussi favoriser l'apparition de troubles psychiques comme la dépression ou les troubles anxieux. À l'inverse, un trouble psychique peut perturber notre sommeil.</p>\n\n<h2>Sommeil et cortisol</h2>\n<p>Le <strong>cortisol</strong> est l'hormone du stress. Sa production est liée à notre rythme de sommeil. Normalement, elle est à son maximum le matin — ce qui nous aide à nous réveiller — puis diminue petit à petit au cours de la journée.</p>\n<p>Un mauvais sommeil peut dérégler cette production. Et quand elle est dérèglée, cela peut provoquer à son tour un mauvais sommeil et une augmentation du stress. C'est un cercle vicieux.</p>\n\n<h2>Des besoins de sommeil différents</h2>\n<p>Il existe des « gros » et des « petits » dormeurs. La durée moyenne d'une nuit de sommeil varie entre <strong>7 et 9 heures</strong>. La durée idéale, c'est celle qui nous permet de nous sentir reposé au réveil et en forme dans la journée.</p>\n<p>Les besoins en sommeil changent aussi au cours de la vie : pendant l'enfance et l'adolescence, on a besoin de plus de sommeil qu'à l'âge adulte. En vieillissant, on peut avoir besoin de moins de sommeil.</p>\n\n<h2>Quand on dort mal…</h2>\n<p>Passer une mauvaise nuit, cela peut être :</p>\n<div class="article-cards">\n  <div class="article-card">\n    <h3>L'insomnie</h3>\n    <p>De grandes difficultés à s'endormir ou à se rendormir après un réveil, des réveils multiples dans la nuit ou très tôt le matin.</p>\n  </div>\n  <div class="article-card">\n    <h3>L'hypersomnie</h3>\n    <p>Dormir beaucoup sans se sentir reposé pour autant.</p>\n  </div>\n</div>\n<p>Un mauvais sommeil peut s'expliquer de nombreuses manières :</p>\n<ul>\n  <li><strong>Raisons physiologiques :</strong> apnée du sommeil, douleurs, bouffées de chaleur, etc.</li>\n  <li><strong>Raisons psychologiques :</strong> préoccupations liées au travail, conflit familial, déménagement, rupture, deuil, difficultés financières, annonce d'une maladie, etc.</li>\n</ul>\n\n<h2>Quand le sommeil se complique</h2>\n<p>Si les difficultés de sommeil reviennent plusieurs nuits par semaine, mieux vaut s'en occuper sans tarder pour éviter qu'elles ne s'installent. Repérer ce qui nous empêche de bien dormir est une première étape pour trouver une solution.</p>\n<p>Tenir un <strong>« journal du sommeil »</strong> permet de mieux connaître son sommeil : on y note ses habitudes de vie (activité physique, usage des écrans, alimentation…) et leurs effets sur la qualité du sommeil, afin d'identifier ce qu'on peut essayer de modifier.</p>\n\n<h2>Que faire si je dors mal ?</h2>\n<p>Enchaîner plusieurs mauvaises nuits peut entraîner un cercle vicieux : plus on dort mal, plus on est fatigué, plus on a du mal à dormir. Voici quelques conseils pratiques pour en sortir.</p>\n<p><strong>Couchez-vous et levez-vous à peu près à la même heure tous les jours</strong>, semaine comme week-end.</p>\n\n<div class="article-highlight">\n  <h3>Avant de vous coucher</h3>\n  <ul>\n    <li>Éteignez les écrans (télé, tablette, smartphone) une heure avant de vous coucher. Mettez le téléphone en mode avion.</li>\n    <li>Évitez les activités stimulantes (sport, travail) juste avant de vous coucher.</li>\n    <li>Limitez les repas trop riches le soir — mais évitez aussi de vous coucher en ayant faim ou soif.</li>\n    <li>Aménagez un espace calme et sombre. Si besoin, bouchons d'oreilles et masque sur les yeux. Température idéale : 18 °C en hiver.</li>\n  </ul>\n</div>\n\n<div class="article-highlight">\n  <h3>En journée</h3>\n  <ul>\n    <li>Pratiquez une activité physique régulière, de préférence le matin.</li>\n    <li>Sortez profiter de la lumière du jour, surtout le matin.</li>\n    <li>Réduisez les excitants (thé, café) après 14 heures.</li>\n    <li>Faites une sieste de 15 à 20 minutes si possible.</li>\n  </ul>\n</div>	sommeil-article.jpg
7	Parler quand ça ne va pas, c'est déjà prendre soin de soi	Quand on va mal, on a parfois tendance à garder ses difficultés pour soi. Pourtant, parler peut être un bon début pour aller mieux.	2025-02-15	f	6	2026-04-01 21:10:49.092111	<div class="article-intro">\n  <p>Quelle que soit la cause de notre souffrance — les soucis du quotidien qui s'accumulent, l'annonce d'une maladie grave, un deuil, une rupture… — il est important de pouvoir en parler à un proche ou à un professionnel de l'écoute.</p>\n</div>\n\n<h2>Parler quand ça ne va pas, ça veut dire quoi ?</h2>\n<p>Quand on sent qu'on ne va pas bien, parler de ses difficultés ou de ses ressentis permet de :</p>\n<ul>\n  <li><strong>Prendre du recul :</strong> raconter ce qu'on vit, mettre des mots sur ses émotions, peut nous permettre d'y voir plus clair.</li>\n  <li><strong>Réduire l'anxiété et le stress :</strong> se sentir écouté, sans être jugé, peut nous apaiser.</li>\n  <li><strong>Trouver de nouvelles solutions :</strong> quand quelqu'un d'autre se penche sur notre situation, cela peut faire apparaître des pistes auxquelles on n'avait pas pensé.</li>\n</ul>\n<p>Parler ne va pas tout résoudre d'un coup, mais c'est souvent une première étape pour commencer à surmonter ses difficultés et, si besoin, pour demander de l'aide auprès d'un professionnel de santé mentale.</p>\n\n<h2>Faire le premier pas pour se faire aider</h2>\n<p>Parfois, on se fait de fausses idées sur le fait de parler de ses difficultés ou de demander de l'aide. C'est ce qui peut rendre cette étape encore plus difficile. Par exemple :</p>\n<ul>\n  <li>On a peur d'être jugé ;</li>\n  <li>On a peur de passer pour quelqu'un de faible ;</li>\n  <li>On a l'impression de déranger, d'embêter les gens avec ses problèmes.</li>\n</ul>\n<p>Mais on a tous une santé mentale : on rencontre tous des difficultés et on a tous besoin de soutien à certains moments de notre vie. <strong>Plus on agit tôt, moins on laisse les difficultés s'installer.</strong></p>\n<p>Pour franchir ce pas, on peut réfléchir à qui on aimerait se confier et au type d'aide que l'on souhaite : partager ce qu'on vit avec un proche, être accompagné par un professionnel de santé mentale, ou obtenir des informations sur des structures d'aide.</p>\n\n<h2>Vers qui me tourner ?</h2>\n<div class="article-cards">\n  <div class="article-card">\n    <h3>Un proche</h3>\n    <p>Un ami, un membre de votre famille, un collègue ou une personne avec qui vous partagez une activité.</p>\n  </div>\n  <div class="article-card">\n    <h3>Une ligne d'écoute</h3>\n    <p>Si vous n'êtes pas à l'aise pour en parler à votre entourage, les lignes d'écoute proposent une écoute bienveillante et sans jugement.</p>\n  </div>\n  <div class="article-card">\n    <h3>Une association</h3>\n    <p>Certaines proposent des groupes de parole pour échanger avec des personnes qui vivent la même situation (deuil, violences, trouble psychique…). Renseignez-vous auprès de votre mairie.</p>\n  </div>\n  <div class="article-card">\n    <h3>Un professionnel de santé</h3>\n    <p>Votre médecin traitant peut vous conseiller. Vous pouvez aussi vous adresser directement à un psychiatre ou un psychologue. Via le dispositif Mon Soutien Psy, jusqu'à 12 séances sont prises en charge par l'Assurance Maladie.</p>\n  </div>\n</div>\n<p>Dans tous les cas, il est important de <strong>ne pas rester seul avec votre souffrance.</strong></p>\n\n<div class="article-warning">\n  <h3 style="color:#991b1b; margin-bottom:0.5rem;">Idées suicidaires — urgences</h3>\n  <p>En cas d'idées suicidaires, pour vous ou pour un proche, contactez le <strong>3114</strong> — numéro national de prévention du suicide.</p>\n  <p style="margin-bottom:0">En cas d'urgence, contactez le <strong>SAMU au 15</strong>. Ces numéros sont accessibles 24h/24, 7j/7, gratuitement et en toute confidentialité.</p>\n</div>\n\n<div class="article-highlight">\n  <h3>L'essentiel à retenir</h3>\n  <ul>\n    <li>Parler est une première étape importante en cas de mal-être.</li>\n    <li>On a tous besoin de soutien à certains moments de notre vie.</li>\n    <li>Il existe différentes formes de soutien adaptées à chaque situation.</li>\n    <li>Plus on agit tôt, moins on laisse les difficultés s'installer.</li>\n  </ul>\n</div>	solitude-article.jpg
\.


--
-- TOC entry 5086 (class 0 OID 16401)
-- Dependencies: 222
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category (id, name) FROM stdin;
1	Stress
2	Anxiété
3	Dépression
4	Burn Out
5	Bore Out
6	Solitude
7	Sommeil
8	Méditation
9	Respiration
10	Prévention
11	Santé mentale
\.


--
-- TOC entry 5095 (class 0 OID 16489)
-- Dependencies: 231
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.favorites (user_id, activity_id, created_at) FROM stdin;
15	7	2026-04-03 20:50:35.283818
14	6	2026-04-05 10:32:30.861738
19	12	2026-04-20 10:10:22.707395
19	6	2026-04-20 10:10:26.721338
\.


--
-- TOC entry 5088 (class 0 OID 16412)
-- Dependencies: 224
-- Data for Name: format; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.format (id, type) FROM stdin;
1	PDF
2	Audio
3	Vidéo
4	Texte
\.


--
-- TOC entry 5097 (class 0 OID 16508)
-- Dependencies: 233
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log (id, user_id, action, description, date_action) FROM stdin;
9	14	Désactivation utilisateur	ID:15 - jeff@o.fr	2026-04-05 11:04:47.355636
10	14	Désactivation utilisateur	ID:16 - bridget@gmail.com	2026-04-05 11:04:48.715231
11	14	Modification article	ID:7 - Parler quand ça ne va pas, c'est déjà prendre soin de soiiii	2026-04-05 11:04:55.700576
12	14	Modification utilisateur	ID:19 - anais@gmail.com	2026-04-05 11:11:08.579848
13	14	Modification activité	ID:8 - Mieux vivre avec la dépression	2026-04-14 09:04:14.492985
14	14	Désactivation activité	ID:8 - Mieux vivre avec la dépression	2026-04-14 09:04:18.005665
15	14	Modification activité	ID:8 - Mieux vivre avec la dépression	2026-04-14 09:04:26.336884
16	14	Modification utilisateur	ID:15 - jeff@o.fr	2026-04-14 09:04:43.561666
17	14	Création activité	ID:9 - Programme MAALSI	2026-04-14 09:30:06.126652
18	14	Modification activité	ID:9 - Programme MAALSI	2026-04-14 09:43:02.883537
19	14	Désactivation activité	ID:9 - Programme MAALSI	2026-04-14 10:07:53.563244
20	14	Création activité	ID:10 - Test cours	2026-04-14 10:08:14.75682
21	14	Désactivation activité	ID:10 - Test cours	2026-04-14 11:07:52.212654
22	14	Upload fichier activité	/static/activities/pdfs/2e45aced76cc45d8a8f453e817b82ff9.pdf	2026-04-14 11:08:55.279067
23	14	Création activité	ID:11 - Test numéro deux	2026-04-14 11:09:07.16286
24	14	Désactivation activité	ID:11 - Test numéro deux	2026-04-14 11:13:16.028915
25	14	Upload fichier activité	/static/activities/pdfs/6d96414d704f4338b4cb46aea4550b2f.pdf	2026-04-14 11:14:28.090323
26	14	Création activité	ID:12 - La motivation au travail	2026-04-14 11:14:52.746267
27	14	Modification article	ID:7 - Parler quand ça ne va pas, c'est déjà prendre soin de soi	2026-04-14 11:34:07.383743
28	14	Upload fichier activité	/static/activities/pdfs/1891c052992645c1b597295b5632c603.pdf	2026-04-23 20:16:01.919372
29	14	Création activité	ID:13 - Test	2026-04-23 20:16:17.622363
30	14	Création activité	ID:14 - Vidéo méditation	2026-04-23 20:16:54.367782
31	14	Désactivation activité	ID:13 - Test	2026-04-23 20:17:58.380525
32	14	Désactivation activité	ID:14 - Vidéo méditation	2026-04-23 20:18:01.45269
33	14	Désactivation utilisateur	ID:21 - deris@gmail.com	2026-04-24 10:07:56.088036
34	14	Upload fichier activité	/static/activities/pdfs/ad09f7effc4b434ca2ac6bedf75ae06f.pdf	2026-04-24 10:12:39.928647
35	14	Création activité	ID:15 - test soutennace	2026-04-24 10:12:50.16234
\.


--
-- TOC entry 5084 (class 0 OID 16390)
-- Dependencies: 220
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role (id, type) FROM stdin;
1	user
2	admin
\.


--
-- TOC entry 5090 (class 0 OID 16423)
-- Dependencies: 226
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, name, surname, email, password, phone, photo, description, role_id, created_at, updated_at, is_active) FROM stdin;
14	Lich	King	lk@cesizen.fr	$2b$12$R.P3uMpIkHXWojX/nXyWAuofxmEsFxCZvZxDYafS7JDbG4PLTPwG2	0298474748	lichking.png	Arthas Menethil était l'héritier de Lordaeron, mais son destin en à voulu autrement et l'a conduit à devenir le tristement célèbre Roi-liche.	2	2026-03-28 12:18:06.424483	\N	t
22	Enora	Broudic	enora@mail.com	$2b$12$eNFDWz/JHyN26B5U8iYnyekDEvXiqH9tlKXt9.irwCGkKr8O6MSxi	\N	\N	\N	1	2026-04-24 07:11:51.587748	\N	t
23	Anais	Kajjaj	poum@mail.com	$2b$12$aLzM75URPBjSxRzBqS8eV.5iMHWyHuM7nZ99tg9Y9XZLBjfzwaA.y	\N	\N	\N	1	2026-04-24 08:05:53.840037	\N	t
21	Deris	Dena	deris@gmail.com	$2b$12$ohSnyl0yl25qnLhaxLZPGeVL1mnvdt32J4p6JXhi3ecAyPD3LLC/q	\N	\N	\N	1	2026-04-23 18:12:20.238408	\N	f
24	alert("hello")	kajjaj	anais@poum.com	$2b$12$kcooFCll/5ywIt4s2xa2Z.LM.mxkWTm27NkjZZOPJeA3UBMn6zkg.	\N	\N	\N	1	2026-04-24 08:11:41.191409	\N	t
11	Jérome	Astier	ddd@gmail.com	$2b$12$YPjmQUMR9TULy6dJLlno.eTgHDsY4eFZRRWvqVc30DMg/LKvLB5ny	0767862565	ddzd.jpg	string	1	2026-03-26 20:09:36.560361	\N	f
18	Varian	Wrynn	hulevent@gmail.com	$2b$12$kt9q36WBs/hatNRhK7qJXuqFIcIE49MsVl8bsb0UTqGqvPjY51IAC	0526397845	\N	\N	1	2026-04-05 08:17:30.905813	\N	t
16	Bridget	Kitten	bridget@gmail.com	$2b$12$aePmqRfbYvdw5dc0N7rKgOMSZqFwgYQroLnCsieGQtY0qTF2I1a3.	0102030405	\N	\N	1	2026-04-05 08:14:16.328112	\N	f
19	Anaïs	Kajjaj	anais@gmail.com	$2b$12$ghgDT9U1CAjwOWgnl6pmYOkBE8SrQ0vVIXMze7e5VhF8YfgNkAuF6	\N	\N	\N	1	2026-04-05 09:08:29.542749	\N	t
20	Geralt	de Riv	the-witcher666@gmail.com	$2b$12$x1K/73ke751FDBfJGByG1OweW.cHN6BCc9iB8BLQaox3e30v9XwiO	\N	\N	\N	1	2026-04-05 09:12:26.018897	\N	t
15	Jeff	Leonard	jeff@o.fr	$2b$12$Opuega3FZbHwQF.t5y9PpO7yMOG5Mj5loQzUpBV6MqSKhPx/Dx49G	\N	\N	\N	1	2026-04-03 18:41:13.105019	\N	t
\.


--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 229
-- Name: activite_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.activite_id_seq', 15, true);


--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 227
-- Name: article_sante_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.article_sante_id_seq', 7, true);


--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 221
-- Name: categorie_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorie_id_seq', 11, true);


--
-- TOC entry 5113 (class 0 OID 0)
-- Dependencies: 223
-- Name: format_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.format_id_seq', 4, true);


--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 232
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_id_seq', 35, true);


--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 219
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_id_seq', 2, true);


--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 225
-- Name: utilisateur_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utilisateur_id_seq', 24, true);


--
-- TOC entry 4924 (class 2606 OID 16478)
-- Name: activity activite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity
    ADD CONSTRAINT activite_pkey PRIMARY KEY (id);


--
-- TOC entry 4922 (class 2606 OID 16458)
-- Name: article_sante article_sante_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_sante
    ADD CONSTRAINT article_sante_pkey PRIMARY KEY (id);


--
-- TOC entry 4910 (class 2606 OID 16410)
-- Name: category categorie_libelle_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT categorie_libelle_key UNIQUE (name);


--
-- TOC entry 4912 (class 2606 OID 16408)
-- Name: category categorie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT categorie_pkey PRIMARY KEY (id);


--
-- TOC entry 4926 (class 2606 OID 16496)
-- Name: favorites favori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favori_pkey PRIMARY KEY (user_id, activity_id);


--
-- TOC entry 4914 (class 2606 OID 16421)
-- Name: format format_libelle_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.format
    ADD CONSTRAINT format_libelle_key UNIQUE (type);


--
-- TOC entry 4916 (class 2606 OID 16419)
-- Name: format format_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.format
    ADD CONSTRAINT format_pkey PRIMARY KEY (id);


--
-- TOC entry 4928 (class 2606 OID 16519)
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- TOC entry 4906 (class 2606 OID 16399)
-- Name: role role_libelle_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_libelle_key UNIQUE (type);


--
-- TOC entry 4908 (class 2606 OID 16397)
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- TOC entry 4918 (class 2606 OID 16439)
-- Name: user utilisateur_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT utilisateur_email_key UNIQUE (email);


--
-- TOC entry 4920 (class 2606 OID 16437)
-- Name: user utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT utilisateur_pkey PRIMARY KEY (id);


--
-- TOC entry 4931 (class 2606 OID 16479)
-- Name: activity activite_categorie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity
    ADD CONSTRAINT activite_categorie_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id);


--
-- TOC entry 4932 (class 2606 OID 16484)
-- Name: activity activite_format_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity
    ADD CONSTRAINT activite_format_id_fkey FOREIGN KEY (format_id) REFERENCES public.format(id);


--
-- TOC entry 4930 (class 2606 OID 16459)
-- Name: article_sante article_sante_categorie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_sante
    ADD CONSTRAINT article_sante_categorie_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id);


--
-- TOC entry 4933 (class 2606 OID 16502)
-- Name: favorites favori_activite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favori_activite_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity(id) ON DELETE CASCADE;


--
-- TOC entry 4934 (class 2606 OID 16497)
-- Name: favorites favori_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favori_utilisateur_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- TOC entry 4935 (class 2606 OID 16520)
-- Name: log log_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_utilisateur_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- TOC entry 4929 (class 2606 OID 16440)
-- Name: user utilisateur_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT utilisateur_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id);


-- Completed on 2026-06-08 21:06:43

--
-- PostgreSQL database dump complete
--

\unrestrict fYNBOJLCJClsGdH3F6Lujappma8BEmnhSzPwet30WaANvN4PqntM9ykOaIOcjye

