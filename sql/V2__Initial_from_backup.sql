--
-- PostgreSQL database dump
--

-- Dumped from database version 11.7
-- Dumped by pg_dump version 11.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: draft_status; Type: TYPE; Schema: public; Owner: webcat
--

CREATE TYPE public.draft_status AS ENUM (
    'unreviewed',
    'reviewing',
    'needs_revision',
    'approved',
    'emailed'
);



--
-- Name: observation_type; Type: TYPE; Schema: public; Owner: webcat
--

CREATE TYPE public.observation_type AS ENUM (
    'positive',
    'neutral',
    'negative'
);



--
-- Name: role; Type: TYPE; Schema: public; Owner: webcat
--

CREATE TYPE public.role AS ENUM (
    'admin',
    'faculty',
    'teaching_assistant',
    'learning_assistant',
    'student'
);



SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name text NOT NULL,
    description text,
    parent_category_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: classroom_categories; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.classroom_categories (
    category_id bigint NOT NULL,
    classroom_id bigint NOT NULL
);



--
-- Name: classroom_users; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.classroom_users (
    user_id bigint NOT NULL,
    classroom_id bigint NOT NULL
);



--
-- Name: classrooms; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.classrooms (
    id bigint NOT NULL,
    course_code text NOT NULL,
    name text NOT NULL,
    description text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: classrooms_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.classrooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: classrooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.classrooms_id_seq OWNED BY public.classrooms.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    content text NOT NULL,
    draft_id bigint,
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: drafts; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.drafts (
    id bigint NOT NULL,
    content text NOT NULL,
    status public.draft_status NOT NULL,
    student_id bigint,
    rotation_group_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    notes text,
    parent_draft_id bigint
);



--
-- Name: drafts_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.drafts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: drafts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.drafts_id_seq OWNED BY public.drafts.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.emails (
    id bigint NOT NULL,
    status text NOT NULL,
    draft_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;


--
-- Name: explanations; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.explanations (
    id bigint NOT NULL,
    content text NOT NULL,
    feedback_id bigint NOT NULL,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);



--
-- Name: explanations_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.explanations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: explanations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.explanations_id_seq OWNED BY public.explanations.id;


--
-- Name: feedback; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.feedback (
    id bigint NOT NULL,
    content text NOT NULL,
    observation_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.feedback_id_seq OWNED BY public.feedback.id;


--
-- Name: grades; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.grades (
    id bigint NOT NULL,
    score integer NOT NULL,
    note text,
    category_id bigint NOT NULL,
    draft_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: grades_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.grades_id_seq OWNED BY public.grades.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    content text NOT NULL,
    seen boolean DEFAULT false NOT NULL,
    draft_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: observations; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.observations (
    id bigint NOT NULL,
    content text NOT NULL,
    type public.observation_type NOT NULL,
    category_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: observations_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.observations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: observations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.observations_id_seq OWNED BY public.observations.id;


--
-- Name: password_credentials; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.password_credentials (
    user_id bigint NOT NULL,
    password text NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.password_resets (
    user_id bigint NOT NULL,
    token text NOT NULL,
    expire timestamp(0) without time zone NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: review_request; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.review_request (
    draft_id bigint NOT NULL,
    user_id bigint NOT NULL
);



--
-- Name: rotation_group_users; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.rotation_group_users (
    rotation_group_id bigint NOT NULL,
    user_id bigint NOT NULL
);



--
-- Name: rotation_groups; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.rotation_groups (
    id bigint NOT NULL,
    number integer NOT NULL,
    description text,
    rotation_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: rotation_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.rotation_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: rotation_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.rotation_groups_id_seq OWNED BY public.rotation_groups.id;


--
-- Name: rotation_users; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.rotation_users (
    user_id bigint NOT NULL,
    rotation_id bigint NOT NULL
);



--
-- Name: rotations; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.rotations (
    id bigint NOT NULL,
    number integer NOT NULL,
    description text,
    start_date date NOT NULL,
    end_date date NOT NULL,
    section_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: rotations_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.rotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: rotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.rotations_id_seq OWNED BY public.rotations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);



--
-- Name: section_users; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.section_users (
    user_id bigint NOT NULL,
    section_id bigint NOT NULL
);



--
-- Name: sections; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.sections (
    id bigint NOT NULL,
    number text NOT NULL,
    description text,
    semester_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    classroom_id bigint DEFAULT 1 NOT NULL
);



--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.sections_id_seq OWNED BY public.sections.id;


--
-- Name: semester_users; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.semester_users (
    user_id bigint NOT NULL,
    semester_id bigint NOT NULL
);



--
-- Name: semesters; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.semesters (
    id bigint NOT NULL,
    name text NOT NULL,
    description text,
    start_date date NOT NULL,
    end_date date NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: semesters_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.semesters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: semesters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.semesters_id_seq OWNED BY public.semesters.id;


--
-- Name: student_explanations; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.student_explanations (
    id bigint NOT NULL,
    draft_id integer NOT NULL,
    feedback_id integer NOT NULL,
    explanation_id bigint NOT NULL,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);



--
-- Name: student_explanations_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.student_explanations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: student_explanations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.student_explanations_id_seq OWNED BY public.student_explanations.id;


--
-- Name: student_feedback; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.student_feedback (
    id bigint NOT NULL,
    draft_id bigint NOT NULL,
    feedback_id bigint NOT NULL,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);



--
-- Name: student_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.student_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: student_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.student_feedback_id_seq OWNED BY public.student_feedback.id;


--
-- Name: token_credentials; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.token_credentials (
    token text NOT NULL,
    expire timestamp(0) without time zone NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);



--
-- Name: users; Type: TABLE; Schema: public; Owner: webcat
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    middle_name text,
    nickname text,
    active boolean DEFAULT true NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    role public.role DEFAULT 'student'::public.role NOT NULL
);



--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: webcat
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: webcat
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: classrooms id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.classrooms ALTER COLUMN id SET DEFAULT nextval('public.classrooms_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: drafts id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.drafts ALTER COLUMN id SET DEFAULT nextval('public.drafts_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);


--
-- Name: explanations id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.explanations ALTER COLUMN id SET DEFAULT nextval('public.explanations_id_seq'::regclass);


--
-- Name: feedback id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.feedback ALTER COLUMN id SET DEFAULT nextval('public.feedback_id_seq'::regclass);


--
-- Name: grades id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.grades ALTER COLUMN id SET DEFAULT nextval('public.grades_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: observations id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.observations ALTER COLUMN id SET DEFAULT nextval('public.observations_id_seq'::regclass);


--
-- Name: rotation_groups id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotation_groups ALTER COLUMN id SET DEFAULT nextval('public.rotation_groups_id_seq'::regclass);


--
-- Name: rotations id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotations ALTER COLUMN id SET DEFAULT nextval('public.rotations_id_seq'::regclass);


--
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.sections ALTER COLUMN id SET DEFAULT nextval('public.sections_id_seq'::regclass);


--
-- Name: semesters id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.semesters ALTER COLUMN id SET DEFAULT nextval('public.semesters_id_seq'::regclass);


--
-- Name: student_explanations id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.student_explanations ALTER COLUMN id SET DEFAULT nextval('public.student_explanations_id_seq'::regclass);


--
-- Name: student_feedback id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.student_feedback ALTER COLUMN id SET DEFAULT nextval('public.student_feedback_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.categories (id, name, description, parent_category_id, inserted_at, updated_at) FROM stdin;
1	Group Understanding	\N	\N	2019-06-25 05:32:14	2019-06-25 05:32:14
2	Group Focus	\N	\N	2019-06-25 05:32:14	2019-06-25 05:32:14
3	Individual Understanding	\N	\N	2019-06-25 05:32:14	2019-06-25 05:32:14
4	Other	\N	\N	2019-06-25 05:32:14	2019-06-25 05:32:14
5	Teaching/ Ensuring the whole group has gained understanding	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
6	Asking Questions	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
7	Coding Issues	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
8	Afraid to disagree with group	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
9	Making a Figure/ Picture of the problem	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
10	Bringing in new/ inappropriate concepts	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
11	Organization	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
12	checking other group members ideas	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
13	Real world ideas	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
14	Contributing ideas to group	\N	1	2019-06-25 05:32:14	2019-06-25 05:32:14
15	Sharing Ideas	\N	2	2019-06-25 05:32:14	2019-06-25 05:32:14
16	Late to class	\N	2	2019-06-25 05:32:15	2019-06-25 05:32:15
17	Not active in discussions	\N	2	2019-06-25 05:32:15	2019-06-25 05:32:15
18	uncomfortable with class style	\N	2	2019-06-25 05:32:15	2019-06-25 05:32:15
19	not making a plan	\N	2	2019-06-25 05:32:15	2019-06-25 05:32:15
20	not focusing in class	\N	2	2019-06-25 05:32:15	2019-06-25 05:32:15
21	one student doing most of the work	\N	2	2019-06-25 05:32:15	2019-06-25 05:32:15
22	listening to tutor's advice	\N	2	2019-06-25 05:32:15	2019-06-25 05:32:15
23	Not prepared for class	\N	3	2019-06-25 05:32:15	2019-06-25 05:32:15
24	overly concerned with the "right answer"	\N	3	2019-06-25 05:32:15	2019-06-25 05:32:15
25	Rigid thinking	\N	3	2019-06-25 05:32:15	2019-06-25 05:32:15
26	not sharing ideas with group	\N	3	2019-06-25 05:32:15	2019-06-25 05:32:15
27	not participating with solving the problem	\N	3	2019-06-25 05:32:15	2019-06-25 05:32:15
28	not asking questions	\N	3	2019-06-25 05:32:15	2019-06-25 05:32:15
29	not doing homework	\N	3	2019-06-25 05:32:15	2019-06-25 05:32:15
30	Four Quadrant Board	\N	4	2019-06-25 05:32:15	2019-06-25 05:32:15
31	leader role dialog	\N	4	2019-06-25 05:32:15	2019-06-25 05:32:15
32	facilitator role dialog	\N	4	2019-06-25 05:32:15	2019-06-25 05:32:15
33	"policing"/ quality control	\N	4	2019-06-25 05:32:15	2019-06-25 05:32:15
34	devil's advocate (critical analyst role)	\N	4	2019-06-25 05:32:15	2019-06-25 05:32:15
35	exam prep	\N	4	2019-06-25 05:32:15	2019-06-25 05:32:15
36	concerned with grades	\N	4	2019-06-25 05:32:15	2019-06-25 05:32:15
55	Teaching / Ensuring the Whole Group has Gained Understanding	Teaching/ ensuring the whole group has gained understanding	53	2019-07-10 17:48:08	2019-08-06 15:37:35
94	Quadrant Board	\N	42	2019-07-10 18:05:33	2019-08-06 15:37:58
99	Devil's  Advocate	\N	42	2019-07-10 18:06:54	2019-08-06 15:38:19
96	Leader Dialogue	\N	42	2019-07-10 18:06:01	2019-08-06 15:38:37
104	Too Concerned Over Grades	\N	42	2019-07-10 18:08:22	2019-08-06 15:39:00
103	Leaving Early	\N	42	2019-07-10 18:07:55	2019-08-06 15:39:31
74	Uncomfortable with Class Format	uncomfortable with the format of P-cubed	49	2019-07-10 17:57:47	2019-08-06 15:40:04
79	Not Focused	\N	49	2019-07-10 17:59:34	2019-08-06 15:40:20
81	One Student Doing the Work	\N	49	2019-07-10 18:00:35	2019-08-06 15:40:49
77	Not Planning	\N	49	2019-07-10 17:59:10	2019-08-06 15:42:26
83	Not Prepared for Class	\N	50	2019-07-10 18:01:46	2019-08-06 15:42:55
72	Not Active in Discussions	\N	49	2019-07-10 17:57:27	2019-08-06 15:43:39
71	Late	\N	49	2019-07-10 17:57:01	2019-08-06 15:43:53
49	GF	Group Focus	\N	2019-07-10 17:41:45	2019-07-10 17:42:46
50	IU	Individual Understanding	\N	2019-07-10 17:43:17	2019-07-10 17:43:17
87	Not Participating in Problem Solving	\N	50	2019-07-10 18:02:50	2019-08-06 15:44:18
93	Not Done Homework	\N	50	2019-07-10 18:05:01	2019-08-06 15:44:40
84	Overly Concerned with Solution	\N	50	2019-07-10 18:02:00	2019-08-06 15:44:57
53	GU	Group Understanding	\N	2019-07-10 17:44:31	2019-07-10 17:44:43
85	Rigid Thinking	\N	50	2019-07-10 18:02:13	2019-08-06 15:45:28
86	Not Sharing Ideas	\N	50	2019-07-10 18:02:28	2019-08-06 15:46:45
66	Contributing Ideas to Group	\N	53	2019-07-10 17:54:54	2019-08-06 15:49:27
64	Checking Other Group Member's Ideas	\N	53	2019-07-10 17:54:10	2019-08-06 15:53:21
42	other	Category for observations that don't fit into the other three categories.	\N	2019-06-27 19:38:50	2019-07-10 17:46:02
65	Real World Ideas	\N	53	2019-07-10 17:54:37	2019-08-06 15:54:19
56	Asking questions	The student asks questions aimed at furthering their understanding as well as that of the group	53	2019-07-10 17:49:17	2019-07-10 17:49:17
62	Bringing in New / Inappropriate Concepts	\N	53	2019-07-10 17:53:24	2019-08-06 15:54:46
58	Coding issues	The individual has issues with group understanding within the context of coding	53	2019-07-10 17:50:27	2019-07-10 17:51:00
60	Afraid to Disagree with Group	\N	53	2019-07-10 17:52:39	2019-08-06 15:55:39
63	organization	\N	53	2019-07-10 17:53:51	2019-07-10 17:53:51
61	Making Figure/Picture of Problem	\N	53	2019-07-10 17:52:59	2019-08-06 15:56:00
98	Quality Control	Helping students learn to troubleshoot their solutions	42	2019-07-10 18:06:40	2019-08-09 13:57:50
114	Deeper understanding	you want students to have a more secure and deeper understanding of the material.	53	2019-08-09 15:31:25	2019-08-09 15:31:25
115	New groups	\N	42	2019-08-13 14:09:15	2019-08-13 14:09:15
67	Sharing ideas	\N	49	2019-07-10 17:55:42	2019-08-13 15:00:47
91	No Questions/ Not answering questions	not asking questions	50	2019-07-10 18:04:21	2019-08-15 14:36:33
105	Coding Issues 2	Capitalization test	53	2019-07-10 19:07:12	2019-07-10 19:07:12
82	Listens to Tutor Advice	\N	49	2019-07-10 18:00:46	2019-08-06 15:36:10
97	Facilitator Dialogue	\N	42	2019-07-10 18:06:18	2019-08-06 15:36:48
110	Ensuring mutual understanding	\N	53	2019-07-19 17:12:49	2019-08-07 15:12:26
109	Coding Issues 3	test	49	2019-07-19 17:12:20	2019-07-19 17:12:20
101	Test Preparation	\N	42	2019-07-10 18:07:33	2019-07-19 17:13:59
\.


--
-- Data for Name: classroom_categories; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.classroom_categories (category_id, classroom_id) FROM stdin;
1	1
2	1
3	1
4	1
1	2
2	2
3	2
4	2
\.


--
-- Data for Name: classroom_users; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.classroom_users (user_id, classroom_id) FROM stdin;
\.


--
-- Data for Name: classrooms; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.classrooms (id, course_code, name, description, inserted_at, updated_at) FROM stdin;
1	PHY 184	Physics for Scientists and Engineers II	Default Classroom	2019-06-25 05:32:14	2019-06-25 05:32:14
2	Phys183	P-Cubed	This is for implementation in the Fall of 2019	2019-06-27 18:16:46	2019-06-27 18:16:46
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.comments (id, content, draft_id, user_id, inserted_at, updated_at) FROM stdin;
1	Approving this draft	9	1	2019-11-04 19:38:21	2019-11-04 19:38:21
2	Submit	9	1	2019-11-04 19:38:33	2019-11-04 19:38:33
\.


--
-- Data for Name: drafts; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.drafts (id, content, status, student_id, rotation_group_id, inserted_at, updated_at, notes, parent_draft_id) FROM stdin;
2	This is my feedback. AAAA	unreviewed	2	2	2019-08-21 19:14:42	2019-08-21 19:18:02	\N	\N
3	jvgkhfgjhv	unreviewed	2	2	2019-08-21 19:19:01	2019-08-21 19:19:01	\N	\N
1	Ayyyyy lmaoo	emailed	2	2	2019-07-25 04:04:21	2019-08-21 19:22:14	\N	\N
4	I need to see that you know the material, so be more active in group discussions, writing on the whiteboards, and working through the calculations.	unreviewed	2	2	2019-08-21 19:23:06	2019-08-21 19:23:06	\N	\N
5	AAAAA	unreviewed	2	2	2019-08-21 19:24:19	2019-08-21 19:24:19	\N	\N
6	aaaaaaa	unreviewed	2	2	2019-08-21 19:24:57	2019-08-21 19:24:57	\N	\N
7	hhhhhhhh	unreviewed	2	2	2019-08-21 19:25:40	2019-08-21 19:25:40	\N	\N
8	I am taking a note that gorup understanding sucked at 3:15	unreviewed	2	2	2019-08-21 19:34:29	2019-08-21 19:34:29	\N	\N
9	This is my feedback	unreviewed	\N	1	2019-11-04 02:10:38	2019-11-04 19:38:06	Ben did a good job on feedback editor	\N
\.


--
-- Data for Name: emails; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.emails (id, status, draft_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: explanations; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.explanations (id, content, feedback_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: feedback; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.feedback (id, content, observation_id, inserted_at, updated_at) FROM stdin;
1	Asking the group about your idea, so that everyone can help solve the problem 	1	2019-06-25 05:32:15	2019-06-25 05:32:15
2	writing out ideas and formulas for group to see	2	2019-06-25 05:32:15	2019-06-25 05:32:15
3	it could also be beneficial to stop and check with your groupmates that everyone is following the process to ensure that nobody is falling behind or confused on a certain aspect of the problem.	3	2019-06-25 05:32:15	2019-06-25 05:32:15
4	This week I would like you to check group understanding periodically throughout the problem by asking understanding type questions	3	2019-06-25 05:32:15	2019-06-25 05:32:15
5	When you’re explaining make sure you go beyond just what you’re doing, but try and explain why you’re doing it. What concept goes along with the math, why does the math work?	4	2019-06-25 05:32:15	2019-06-25 05:32:15
6	You can do this by being the main person that updates the quadrants board, or rewriting the solution for the group if they get lost, or helping the group recap what you all have done when the group gets stuck.	5	2019-06-25 05:32:15	2019-06-25 05:32:15
7	 Make sure that as you write out simplifications and equations that you’re checking in with your group members and making sure that they can write out what you are,	6	2019-06-25 05:32:15	2019-06-25 05:32:15
8	test	8	2019-07-10 18:19:45	2019-07-10 18:19:45
9	Asking the group about your idea, so that everyone can help solve the problem. This way everyone gets to practice solving the problem, and the solution will likely be improved with more contributors	8	2019-07-10 18:21:21	2019-07-10 18:21:21
10	write out ideas and formulas for group to see. helps  everyone to understand each part of the problem, and keep track of information better	9	2019-07-10 18:22:19	2019-07-10 18:22:19
11	it could be beneficial to stop and check with your group mates that everyone is following the process to ensure that nobody is falling behind or confused on a certain aspect of the problem. Generating group discussions that involve all four group members is a good way of gauging where everyone is at and can bring forth even more of an understanding and ideas.	10	2019-07-10 18:24:00	2019-07-10 18:24:00
12	When you’re explaining make sure you go beyond just what you’re doing, but try and explain why you’re doing it. What concept goes along with the math, why does the math work? This can be a good check of the legitimacy of the approach your taking but also ensures equal understanding. 	12	2019-07-10 18:26:34	2019-07-10 18:26:34
13	You can solve this by being the main person that updates the quadrants board, or rewriting the solution for the group if they get lost, or helping the group recap what you all have done when the group gets stuck. It’s beneficial to do this because sometimes, the methods you all come up with are not structurally sound or use equations that aren’t relevant. Sometimes, the group needs to hear someone repeat what they’ve done so far as well because someone may not have been following along, or hearing it repeated back can reveal the parts of it that don’t make sense. 	13	2019-07-10 18:30:52	2019-07-10 18:30:52
14	explain your ideas to your group members when you have them. this helps to solidify both your ideas, as well as those of the group.	14	2019-07-10 18:45:01	2019-07-10 18:45:01
15	practice writing out the math in addition to vocal discussion. This can help a ton with keeping your work on track and can be a great tool to help validate your work.	16	2019-07-10 18:52:40	2019-07-10 18:52:40
16	practice writing equations out in variables so your group members see where you are in the project.It's important that group members use their prior experiences to enhance the group as well as their own understandings	17	2019-07-10 18:54:20	2019-07-10 18:54:20
17	in the future, ask your group members before coming to me. This will enhance your as well as your group members' understandings	18	2019-07-10 18:55:53	2019-07-10 18:55:53
18	In order to be better prepared for class and thus less likely to become frustrated, review the notes, review the pre-class homework. This will help you be as prepared for class as possible and will eliminate the frustration of not knowing topics in the project	19	2019-07-10 18:57:55	2019-07-10 18:57:55
19	One lesson you will likely learn quickly about this course is this: you get what you give.	15	2019-07-11 00:09:42	2019-07-11 00:09:42
20	 try to make more of an effort to not only advance your group’s solution to the problem, but to advance your group’s understanding of the physics.	20	2019-07-11 00:11:18	2019-07-11 00:11:18
21	Be sure to update the board throughout the course of the problem, and try to be very explicit with what you write/what you are asking.	21	2019-07-11 00:13:23	2019-07-11 00:13:23
22	speak up more. Asking questions of the group establishes that everyone is/isn’t on the same page, and can often be a huge help to the group!	22	2019-07-11 00:16:20	2019-07-11 00:16:20
23	It’s totally OK to get the group to stop moving forward so that you can all stay on the same page. This Helps to solidify the understanding of whomever is asking the question, as well as that of your other group members	23	2019-07-11 00:20:09	2019-07-11 00:20:09
24	Make sure to keep engaging with the other members of the group in this way. These contributions will help your group out immensely.	24	2019-07-11 00:21:02	2019-07-11 00:21:02
25	 I want you all to remember that getting the right answer isn’t as important as pushing each other to develop a deeper understanding of the physics.	25	2019-07-18 12:11:39	2019-07-18 12:11:39
26	try to take a step back, look at the math happening on the board, and try to see the bigger picture. Ask your group, “how does what we are doing here help get us toward our goal?” This will help your group tremendously with staying focused.	26	2019-07-18 12:13:38	2019-07-18 12:13:38
27	 For next week, I want you to question what your group is doing and why at various points during the day. Play a sort of devil’s advocate for your group members. This will help make sure that everyone in the group always is focused about what is being solved for, and this will help tremendously in group focus.	27	2019-07-18 12:15:39	2019-07-18 12:15:39
28	 Keep it up! 	28	2019-07-18 12:17:52	2019-07-18 12:17:52
29	 If your group members are talking quickly and it is harder to keep up with, math is one very powerful way to communicate and by writing the equations out on the whiteboard you can help your group see what your thoughts are.	29	2019-07-18 12:20:07	2019-07-18 12:20:07
30	spend more time filling out the “assumptions” part of the four quadrants board, and discussing it .One of the most important parts of these problems is recognizing what things we’re choosing to assume, and what things are assumed when we use certain techniques. This will be a crucial part of the group exam, and so starting to practice with it now will help you feel more confident with it when the exam comes around	30	2019-07-18 12:23:28	2019-07-18 12:23:28
51	test	33	2019-07-18 17:11:46	2019-07-18 17:11:46
31	One thing that I would like you all to improve on as a group is your use of the four-quadrant board, as this can help a lot during the problem-solving process and it is important for the exam coming up in a few weeks. When working through the problem, you should be using the quadrant board as a way to organize and justify your work. The facts and lacking quadrants are very helpful when you get stuck in a problem because they’re a way to gather all of the information you have into one place, making it easier to see connections between different variables that can help you along when solving the problem.	31	2019-07-18 12:26:09	2019-07-18 12:26:09
32	 If you ever get stuck when solving the problem, as I said last week, use the learning goals to help guide your solution. 	32	2019-07-18 12:31:18	2019-07-18 12:31:18
34	You demonstrated a good understanding of the concepts last week, however not everyone seemed as confident in the topics. Try to watch out for these gaps in understanding within your group and do your best to make sure everyone is on the same page before continuing on through the problem.	10	2019-07-18 12:34:55	2019-07-18 12:34:55
45	it is also important to make assumptions about the actual hovercraft and not just external factors.	45	2019-07-18 13:44:25	2019-07-18 13:44:25
35	 If there is a disagreement on methods, the group should discuss and come to a consensus.This will lead to less confusion and more cohesive understanding.	34	2019-07-18 12:40:02	2019-07-18 12:40:02
36	As we move into future weeks it would be beneficial to have all the group members code at least once within a project.This will help unexperienced members start to ease into the code and gain a solid comprehension of it.	35	2019-07-18 12:47:46	2019-07-18 12:47:46
47	 it is very beneficial to students to physically write things out on the whiteboard as writing down ideas in addition to vocalizing them aids in your retention of that information	47	2019-07-18 13:54:29	2019-07-18 13:54:29
37	Next week I would like you to help further bridge the ideas within the group. I understand that is may be a difficult task, but it can be as simple as just saying “hey I like that idea, what does everyone else think.” Which may help to remind everyone that the whole group is working towards the solution together	36	2019-07-18 12:49:38	2019-07-18 12:49:38
38	I would suggest reading the notes, making sure you do the homework, and coming prepared for class. This would help improve your understanding of the projects, and really help your group.	37	2019-07-18 12:51:46	2019-07-18 12:51:46
41	Another great way to keep up momentum is to bring the learning goals to your group's attention each week. By doing this, you can help the group decide which ideas are in line with the goals of the problem and which ideas are more off topic.	41	2019-07-18 13:06:11	2019-07-18 13:06:11
42	try to keep track of what equations you use, where they come from, and why you want to use them. Reason with each other as to why using an equation is appropriate (i.e. does it apply to the situation? What is the situation it can be used in?) and if it makes sense to use in order to achieve your goal. This ‘checking’ process can be classified as making sure you have evidence for your reasoning, and it’s an important skill to develop for group exams	42	2019-07-18 13:08:52	2019-07-18 13:08:52
44	Another thing to work on is showing more variables when doing calculations – this helps to make the work clearer and can help you all to see when variables cancel.	44	2019-07-18 13:33:25	2019-07-18 13:33:25
48	Remember, your group is not graded on how quickly you get through the problem/find a solution. The organization and group’s collective discussion/understanding is much more important.	38	2019-07-18 13:58:01	2019-07-18 13:58:01
39	 I suggest, if you feel that you disagree with an idea not to simply put it down, but to try to explain your reasoning. Explain through the material that you know (such as equations or laws) as to reasons why you disagree.	39	2019-07-18 12:56:24	2019-07-18 12:56:24
50	On coding days, it’s important each group member gets a chance to type and dissect the code as it will be one of the questions on your first exam, and you will need to be able to interpret and modify it successfully.	48	2019-07-18 15:11:29	2019-07-18 15:11:29
40	As we move into next week, take that strategy you used with helping your group explain code and apply it to the more analytical parts of the problem. Try to keep the group together on each step of the problem while checking that everyone is getting their individual understanding out of it.	40	2019-07-18 13:02:48	2019-07-18 13:02:48
43	Since you are inexperienced in the subject you’ll have a more concrete, or dictionary, understanding of the concepts since you’re going through the notes more carefully, so don’t be afraid to push back on anything that doesn’t agree with your current understanding. You’ll either learn more about how to use the concept or save the group from making small errors! 	43	2019-07-18 13:31:25	2019-07-18 13:31:25
46	please feel comfortable letting me know if I am moving too fast. And, the same goes for your groupmates. It is beneficial to the group discussion when you speak up and bring other ideas or concerns to the group	46	2019-07-18 13:50:34	2019-07-18 13:50:34
49	Try not to move forward until everyone is on the same page. This means that if someone isn’t in agreement with the solution it is necessary to stop and convince them with justified reasons based on the physics. It also means that if you’re sure you know the answer you still need to make sure the others are too. 	49	2019-07-18 15:08:16	2019-07-18 15:08:16
33	Whenever you make assumptions (e.g. no air resistance, no friction, constant velocity, etc.) that allow you to solve the problem in a less complicated way, you need to strictly say that you made those assumptions in order to validate your solution. 	33	2019-07-18 12:32:58	2019-07-18 17:13:02
52	You all need to be working together as a unit; sharing ideas, asking each other questions, listening to each other, and thinking critically about the work you’re doing -- not just writing down arbitrary equations and assigning them values.	50	2019-07-24 16:14:06	2019-07-24 16:14:06
53	For future class periods I want you all to come having read the notes. I also want you to take your own notes on the resources found on lon-capa, and bring those to class. I will be looking for this. Additionally, spend more time during the pre-class homework assignments trying to understand the concepts instead of just getting the right answers. It is vital that you all understand the core physics topics being discussed as in the end you have to take each exam individually in addition to the group exams. 	15	2019-07-24 16:16:16	2019-07-24 16:16:16
54	Next week, I would push to give your group mates an opportunity to go through the calculations for themselves, with your assistance. Also, if you see your group members aren’t following along with what you’re doing, or seem lost, make sure to slow down and really explain the physics concepts you’re using.	51	2019-07-24 16:18:23	2019-07-24 16:18:23
55	I need to see that you know the material, so be more active in group discussions, writing on the whiteboards, and working through the calculations.	22	2019-07-24 16:20:11	2019-07-24 16:20:11
56	It’s important that you do not just blatantly accept anything that your group members write down on the board. Don’t hesitate to double check equations that people have written down by either reworking the algebra yourself or referring to the online notes in class.	52	2019-07-27 19:46:43	2019-07-27 19:46:43
57	This week, before you begin to really dive into the problem, talk it over with your group and come up with a brief plan as to how you will solve the problem, considering your end goal and what you will have to find to get there. 	53	2019-07-27 19:50:49	2019-07-27 19:50:49
58	Thus, I would suggest for you to continue asserting yourself in the group and making sure your ideas are discussed among the whole group. This may be a difficult thing to do, especially if a discussion gets heated, but perseverance will result in a better understanding of the Physics of the problem for everyone in your group. 	54	2019-07-28 10:16:05	2019-07-28 10:16:05
59	Getting the correct answer is not the goal of this class, it's more important that you work through the problem, gaining a better understanding of Physics	55	2019-07-28 10:29:03	2019-07-28 10:29:03
60	I understand that your group tends to go fast, but feel free to ask them to slow down. This will better your group and individual understanding	56	2019-07-28 10:32:18	2019-07-28 10:32:18
61	let’s keep building on our planning skills by focusing on making connections between equations. Learning to make these connections will not only help your group's ability to solve problems but will also improve your understanding of how the topics we cover in class relate to one another.	57	2019-07-28 10:47:12	2019-07-28 10:48:14
62	before you complete the problem, make sure you are talking as a group about the learning goals and why the steps you are taking and the equations you are using work.	59	2019-07-28 11:14:42	2019-07-28 11:14:42
63	It would be helpful for the groups understanding if while solving the problem you were to ask questions of the other group members to make sure that they are on the same page. This can also help catch mistakes made in the solution the group is working on.	60	2019-07-28 11:19:02	2019-07-28 11:19:02
64	There are many resources available to help you better work with the coding days in this course. The help room is a great resource for this. Simply bring any questions you may have, or let the LA know which coding problem you would like to go over, and they will be happy to help	61	2019-07-28 13:03:28	2019-07-28 13:03:28
65	 It would be beneficial to your groupmates’ understanding if they were to explain your group’s reasoning on their own. This is a key element of the group understanding portion of your grade; allowing others to explain themselves effectively is one of the best ways for them to reinforce their connections to the material	62	2019-07-28 13:08:35	2019-07-28 13:08:35
66	The more people work through equations, the more sure you can be sure of your answer.  Also this promotes each group member to get more involved and share ideas.	47	2019-07-31 14:06:18	2019-07-31 14:06:18
67	When working on future problems, I encourage you to keep working through the calculations and encourage group members to do the same.  The more people work through equations, the more sure you can be sure of your answer.	63	2019-07-31 14:52:32	2019-07-31 14:52:32
68	Next week, come in with an understanding of all of the relevant equations and try to develop a solid plan with the necessary assumptions before we have lengthy discussion. This will help prepare you for the structure of the group exam as well as focusing on assumptions that help simplify the physics in the problem.	64	2019-07-31 14:56:30	2019-07-31 14:56:30
69	continue to build on these by asking yourself ‘why’ the assumptions are meaningful as well as how they change the solution.	65	2019-07-31 15:18:46	2019-07-31 15:18:46
70	It's vital that each of you while going through the problem, are vocalizing any disagreements you may have with how concepts are being implemented in the problem this will not only enhance your own understanding of the problem, but also the understanding of whoever is proposing the idea to solve the problem as it forces both parties to explain how and why they believe the physical concepts in the project relate.	66	2019-07-31 15:23:59	2019-07-31 15:23:59
72	 It can be a distraction as well as removes you from the group, leaving one less person focused on solving the problem.	68	2019-07-31 15:38:59	2019-07-31 15:38:59
71	Try to write your steps in a cohesive manner that makes it easy for someone outside the group to follow and keeping all your equations in variable form as long as possible.	67	2019-07-31 15:37:48	2019-07-31 15:37:48
80	It would be beneficial to your group to take a more active role. Try writing out your ideas on the whiteboard, or add information to the 4-quadrants board as you learn more about the problem benefits group focus and understanding. 	65	2019-08-07 13:56:50	2019-08-07 13:56:50
99	Take some time out of the beginning of class to really consult with your group on what everyone thinks should be done – try to support everyone’s claims with facts from your notes or from online, and get equations out there that support what you want to do. You have the tools, all you have to do is use them!	82	2019-08-07 15:24:51	2019-08-07 15:24:51
73	You're all doing well staying organized the way you have, but I want you to practice using the board effectively so when you're recording your work on the group exam it will feel more natural. 	31	2019-08-01 14:01:30	2019-08-01 14:01:30
77	You won’t be able to ask questions during the group exams, so it’s important to develop problem-solving strategies as a group.	50	2019-08-07 13:47:31	2019-08-07 13:47:31
74	start questioning your conclusions. When you're starting to come out with answers to the problem or certain parts of the problem look at the values or conclusions and evaluate them with what you think should be happening. You should be able to recognize if the order of magnitude is off or if a unit isn't correct, or if the answer seems odd.	69	2019-08-01 14:04:14	2019-08-01 14:04:14
75	Make sure to keep this up, you're really taking to the group portion of the course! 	70	2019-08-01 14:07:26	2019-08-01 14:07:26
98	The most important thing for you is to manage how much work you do – you cannot shoulder the weight of solving the problem all on your own. If you see yourself being the only one doing writing or calculating, stop and ask your group members what they think should be done. 	63	2019-08-07 15:19:41	2019-08-07 15:19:41
102	You are encouraged to disagree with your group members or to slow your group down if you have a question. These are the points where you can learn the most in this class! 	54	2019-08-08 14:17:39	2019-08-08 14:17:39
103	I’d like to see you try to get [insert name] more engaged with the group. Ask him what he thinks about some idea, ask him to check your calculations, or encourage him to write out his ideas on the white board	78	2019-08-08 14:24:57	2019-08-08 14:24:57
76	It’s very important to talk to each other because everyone may understand a different piece of the solution and by discussing it you can put them all together.	50	2019-08-07 13:46:04	2019-08-07 13:46:04
104	Everyone should be writing on their portion of the whiteboard, even if someone else has already written the math on their portion. It’s important to be able to set up the mathematics and carry out the calculations yourself. This will help solidify your own understanding and help you identify parts of the solution you may not understand.	84	2019-08-08 14:29:43	2019-08-08 14:29:43
78	This class is formulated so ideally, I don’t give you any answers, as a group you all work together to develop your understanding. In fact, getting the right answer everyday has no effect on your grade, what matters is the work you put in each day, how you work in your group, and how well you work to understand the concepts. 	25	2019-08-07 13:49:13	2019-08-07 13:49:13
82	I liked the overall style of your group's collaborative work. You as a group showed interest in understanding and solving the problem, everyone had a chance to contribute ideas, although at differing levels. It can be beneficial for the group to round out discussions, but overall great job balancing group members contributions. 	73	2019-08-07 14:08:54	2019-08-07 14:08:54
88	You got the lucky spot of sitting next to the quadrants board! Another way to improve your group’s communication is to encourage those by the quadrants to ask their other group members what should be included. And not just at the beginning of class! ‘Facts’ should be updated every time a new number (or concept) is discovered, which could be important for other parts of the problem. 	74	2019-08-07 14:31:52	2019-08-07 14:31:52
89	My first request for you is to disclose any information to your group you have pertaining to the concepts and equations as soon as you feel they are applicable – you had some good information and ideas but didn’t really voice them until I came around. If at all you notice your group starting to get stuck, immediately turn your head to ‘what does the problem want’ and then ‘what do I know that can get us there.’ 	77	2019-08-07 14:36:47	2019-08-07 14:36:47
92	The main problem the group had was jumping steps in the problem-solving process and you all have a role to play in being more systematic in your approach. 	79	2019-08-07 14:56:25	2019-08-07 14:56:25
79	Making sure your group is on the same page is super important. If the group isn’t on the same page it makes it much harder to have discussions about the problems and you might miss out on important insight from group members.	71	2019-08-07 13:54:02	2019-08-07 13:54:02
81	There will be times that you guys will get stuck in class and won’t be really sure what to do next. This is when the group members should be sharing any ideas they have. There are four of you working together and one person mentioning any idea that comes to mind can spark discussion and can end up benefitting everyone in the group. 	72	2019-08-07 14:01:57	2019-08-07 14:01:57
83	I noticed you didn't use the quadrants that much, for example, you didn't spell out the approximations and assumptions. I encourage you to use this tool and concise notation to sharpen the way you think about a problem. 	65	2019-08-07 14:12:12	2019-08-07 14:12:12
84	This upcoming week, try to keep these ideas organized by keeping your four-quadrant board updated. When you guys get a new number, add it to the facts quadrant. When you guys have an idea to solve the problem, add it to the assumptions quadrant. You can use that board to not only make your initial plan but to keep track of where you guys are on the problem.	74	2019-08-07 14:17:54	2019-08-07 14:17:54
90	Good group discussion is key in this class, so in the upcoming weeks, I’d like to see you initiate some in-depth group debates and discussions – especially when it seems like you guys are in a lull. 	78	2019-08-07 14:39:37	2019-08-07 14:39:37
91	For next week, I would like to see you take on a leadership role on the coding days were you take on a guiding role and do as little typing as possible and much more of guiding your other group members and help them to interpret the code. This may be a bit frustrating at first and might involve some patience but it will really help out your fellow group members in the long run. 	48	2019-08-07 14:50:56	2019-08-07 14:50:56
93	Spend the first part of class just reading the problem, filling out the key information in the four quadrants, and make a general outline for the order you think it would make sense to solve the problem, and then maybe what formulas or concepts you think would help you along the way. Then call me over so I can go over the plan with you guys. Learning how to make a good plan now will really help you guys work through the problems and help on the group exam! 	79	2019-08-07 14:59:14	2019-08-07 14:59:14
101	Only one group member was doing the calculation and the whole group was waiting to see the result. You should always try to check each other’s math or participate in finding solutions. Also bringing a calculator to class will make it easier for everyone to participate equally.	63	2019-08-08 14:15:01	2019-08-08 14:15:01
105	Encourage your group members to do some of the coding, even if it slows down your group, try passing the laptop to someone who hasn't coded you.	48	2019-08-08 14:31:34	2019-08-08 14:32:02
85	There were times as a group where everybody was contributing thoughts, but you were quiet. Even if you agree with someone, let the group know because it is important that your group choose a direction to go with the problem.	75	2019-08-07 14:22:33	2019-08-07 14:22:33
86	No matter how many ideas you’ve considered, you have to all come to a consensus on one and roll with it – that means, never stop talking about possible ideas. Offer equations you learned about. Open up the class notes and discuss themes from the week. 	76	2019-08-07 14:25:16	2019-08-07 14:25:16
94	One thing I push you to do is for you to try and get your group members to share their ideas. It seemed like you carried most of the conversation, maybe ask a question here and there to get your group thinking and coming to a solution together. Just some food for thought.	63	2019-08-07 15:04:05	2019-08-07 15:04:05
87	The next time a coding problem comes around, as well, encourage your groupmates to give it a try. Sometimes, coding is best practiced by teaching those around you what you know	48	2019-08-07 14:27:45	2019-08-07 14:27:45
95	For the most part, it seemed like you knew what was happening within the problem, but most of it came through group conversation and explanation. Challenge yourself and critically analyze the problem to figure out what is happening, sharing your original ideas and discussing them with your group will only strengthen your understanding.	80	2019-08-07 15:07:22	2019-08-07 15:07:22
96	[exaple of a good idea the student had] even though this wasn't quite the way to solve it, contributing ideas and attempting problems is all part of the problem-solving process and is essential for understanding.	81	2019-08-07 15:10:04	2019-08-07 15:10:04
97	You had many equations and drawings in front of you, which is important information that your group needed. Don’t let yourself be the only one doing this, however, because it seemed like your group was starting to become reliant on your work to get them through the problem. Your first task is always to ask your other group members for their opinions on what they think they should do. 	63	2019-08-07 15:13:46	2019-08-07 15:13:46
100	If possible try to get to class at least 5 minutes early, and try not to leave in the middle of class. It really slows the group’s progress down to have to catch people up on what they missed, especially when it happens several times a class period.	83	2019-08-08 14:08:22	2019-08-08 14:08:22
106	I did notice it seemed that not everyone felt comfortable asking questions and just moved on with the problem. Asking questions or admitting you don’t understand something does not hurt your grade it helps because it shows a desire to really want to learn and increase your individual understanding	85	2019-08-08 14:35:06	2019-08-08 14:35:06
107	I realized that many of you didn't really study the lecture notes available on the Pcubed course web page, and as a consequence struggled with basic equations. It is really important that you come to class sufficiently prepared in order to gain an understanding of the physics concepts.	15	2019-08-08 14:45:44	2019-08-08 14:45:44
108	I know that you have some physics experience, so you may not need to slow down and analyze the process, but other members of the group may not understand as well as you, so use that experience to help make the discussions more meaningful.	17	2019-08-08 14:49:21	2019-08-08 14:49:21
109	Make sure everyone understands something before the group moves on to the next part. You can ask people to explain something back to you or ask them questions if they seem hesitant about part of the problem.	86	2019-08-08 14:53:33	2019-08-08 14:53:33
110	You also contributed ideas to the group well and shared your thoughts but you didn't always discuss your ideas with your group. [example of the situation]. Try actively discussion your idea with your group members by introducing important equations or concepts. Then decide together if that is the route you want to take. 	88	2019-08-08 15:03:55	2019-08-08 15:03:55
111	As the most experienced in the group, your hands should be anywhere but the computer for most of the class period. There was a couple of times in class that you collected the computer in your own space, and though the computer was still facing everyone, you have to be sure you’re telling your group what you’ve changed and why. 	89	2019-08-08 15:06:07	2019-08-08 15:06:07
112	Make sure you come to class prepared - that is, we assign the pre-class homework so that you all come to class with a basic idea of what you'll be working with. I see that you haven't done much of the homework so far, and I'd really encourage you to begin doing them. It helps you get the most out of class time, and not doing the homework will really affect your grade.	90	2019-08-08 15:07:57	2019-08-08 15:07:57
113	Something I think you can do to improve is to also get more involved in carrying out calculations and setting up equations. It's important for each of you to get hands-on practice carrying out the solutions to solidify your own understandings.	16	2019-08-08 15:15:18	2019-08-08 15:15:18
114	I think your group is benefiting from your leadership, and one way you could lead even more effectively would be to try and draw out your groupmates' ideas more by asking them explicitly what they think. This can help get more ideas on the table and help everyone come to a better understanding.	78	2019-08-08 15:16:19	2019-08-08 15:16:19
115	I noticed how if one of your group members doesn’t seem to understand something you do a good job of explaining it to them. This helps the group stay on the same page, so nobody is feeling left behind.	91	2019-08-08 15:18:48	2019-08-08 15:18:48
116	Not everyone was writing on the board, and not everyone had a marker. Next week make sure that everyone has their own marker so it’s easy for everyone to write on the board.	9	2019-08-08 15:20:57	2019-08-08 15:20:57
117	When you suggest an idea try asking a specific group member what they think about it or ask them to check your idea. It’s important to keep everyone involved in the discussions because everyone has a different understanding of the problems and can contribute something different, but only if they’re involved in what the group is doing.	49	2019-08-08 15:22:48	2019-08-08 15:22:48
118	I noticed you do a great job of speaking up when you don’t agree with what the group is doing. That is a great thing to do because it gives you a chance to check your own understanding and it also helps insure that the group is going in the right direction.	92	2019-08-08 15:24:55	2019-08-08 15:24:55
119	It would be helpful to explicitly write in the quadrants what it is you are trying to achieve or obtain in the problem - in other words, what is the end goal. Keeping this as the reminder should help with the organization because every idea that comes up can be reflected on this goal and you all can ask yourselves “how does this idea help achieve that goal”.	79	2019-08-08 15:27:32	2019-08-08 15:27:32
120	I would like to see more of this understanding being integrated into the group before we get to the end. What this means for you is that I would like you to play the skeptic a bit, when ideas are introduced make sure to analyze them from the perspectives does this make sense to me, has this ideas been explained enough to me for the group to understand, will this idea help reach our end goal. 	93	2019-08-08 15:31:00	2019-08-08 15:31:00
121	It is important that if you become stuck to ensure that you reflect on your approach and try to identify the step in your plan where things didn’t add up or didn’t make physical sense. This can be a tough skill to learn but troubleshooting is important in any scientific or engineering endeavor, so making sure to layout your solution in logical steps that you then can return to each step and ask did this make sense is a good first step to learning this skill. 	42	2019-08-08 15:33:00	2019-08-08 15:33:10
122	Your focus seems to drift on occasion in class and the main thing I would like to see in this coming week is you fully involved for the duration of the class. Again, being involved doesn’t mean you have to be coming up with the solution by yourself, it just means that you are paying attention to what your group is doing so that if there is a gap in your understanding you can ask questions to clarify what is going on.	94	2019-08-08 15:38:14	2019-08-08 15:39:57
123	It’s okay to have different ideas from the group, I just want you to explain them to your group as you work on them, and make sure you have a reason for your ideas. Don’t just plug things into formulas, try and think about the concepts and formulas.	66	2019-08-09 14:07:27	2019-08-09 14:07:27
124	When you have a question or a concern try directing them to your group first because someone in your group might have a good explanation. You should then work through the problem with you group to the best of your ability. This way you’ll gain a better individual and group understanding, than if you just ask me for answers.	95	2019-08-09 14:13:37	2019-08-09 14:13:37
128	Your diagrams in the representations quadrant could be stronger. Your diagram should be large, clean, and descriptive. And during the two sessions this week, your representations section was lacking detail	98	2019-08-09 14:29:53	2019-08-09 14:29:53
125	Even if someone has already written out the math, it would be beneficial for you and the rest of the group to do the math as well. You may catch an error that your teammate made, or you may find that you weren’t able to carry out the calculation on your own. 	47	2019-08-09 14:17:45	2019-08-09 14:17:45
126	You tried some things during the programming session, but then you let your team take over around the end. Ask your group to let you try to code. This is because, you are learning a new skill (programming) and it is important that they are supportive and patient as you broaden your skillset. 	96	2019-08-09 14:22:28	2019-08-09 14:22:28
131	I did notice there was someone dominating the group, even so, I really want you to question the ideas others give to create discussion when that happens. Just because someone is leading the conversation does not mean they are leading it in the right direction. So this upcoming week I really want to push you to bring up your ideas earlier and push heavily for a discussion all the ideas proposed	100	2019-08-09 14:51:31	2019-08-09 14:51:31
133	Sometimes, I think you let your previous physics experience work against you, especially, when you bring in topics that we aren’t working on that week. To help with this, I suggest you look through the learning goals on the problem before you come up with a plan with the group on how to solve the problem. This will help keep you all on the right path and help you all make sure you’re getting familiar with the topics you’ll need on the exam.	101	2019-08-09 15:00:20	2019-08-09 15:00:20
141	You act as an excellent facilitator between your group mates and make sure that you take everyone’s ideas into consideration. This leadership role is an important one for someone to take on and I feel that you would be a good fit as your enthusiasm helps encourage participation and is most likely one of the reasons why your group functions so well together.	60	2019-08-09 15:16:27	2019-08-09 15:16:27
143	It is great that you have this understanding, but with good understanding becomes the responsibility to communicate it to your other group members.	106	2019-08-09 15:20:27	2019-08-09 15:20:27
160	I know you’re focused in class, but you're not presenting a lot of your own work or justifcations- relying heaviy on your group. You’re not going to have this sort of group luxury during the individual portion of the exam, so your task for this next week is to take some initiative and provide real, solid proof from your own sources to back your ideas. Bring in some notes that you’ve written if you have any, or have conversations with your group members about why you want to approach the problem in your way.	25	2019-08-09 15:44:28	2019-08-09 15:44:28
127	I’d like to see you trying to engage the rest of your group more in solving the problem. Once you have set up the problem, make sure the rest of your group has the math written out in front of them before you proceed to solve the problem. Ask your other group members what they think, and don’t move on until they’ve given you a solid answer. At this point, it seems like you’re pulling most the weight for your group, and I’d like to see you try to get your other group members more involved. 	97	2019-08-09 14:27:09	2019-08-09 14:27:09
129	Remember to write out everything on your portion of the workboard and make sure that you can get to the correct result by yourself even if that means asking your group to clarify. 	16	2019-08-09 14:41:40	2019-08-09 14:41:40
151	I would really like to see you write out work on the whiteboard. On the Individual Exam, you're going to have to be the one that makes decisions without being able to ask your group members, so, the more practice you get the better. For example, you could offer to write out the equations that you read about in the lecture notes, or you could help out whoever is performing the calculations -- or even better, offer to do the calculations yourself	103	2019-08-09 15:28:14	2019-08-09 15:28:14
161	I know you’re focused in class, but you're not doing a lot of your own work-relying heavily on your group. You’re not going to have this sort of group luxury during the individual portion of the exam, so your task for this next week is to take some initiative and provide real, solid proof from your own sources to back your ideas. Bring in some notes that you’ve written if you have any, or have conversations with your group members about why you want to approach the problem in your way.	103	2019-08-09 15:45:18	2019-08-09 15:45:18
130	You seem to be carrying most of the weight for your group, especially in terms of calculations, and I’d like to see you try to let your group do a little more of the work for themselves. For example, before you give them the solution, make them solve the equation themselves and then reveal your solution and see if they match. Great job this week!	99	2019-08-09 14:46:17	2019-08-09 14:46:50
132	You really need to be able to allow your group to contribute, a good way of doing this is asking them if they have any ideas instead of only working on your ideas you. There were a few times where ideas were given and not taken into account when they were incredibly helpful ideas and would have helped to solve the problem more efficiently. So in the upcoming week I want you to take a small step back and make sure everyone ideas are heard and everyone gets a chance to contribute to doing the work	100	2019-08-09 14:55:52	2019-08-09 14:55:52
144	It is great that you have this understanding, but with good understanding becomes the responsibility to communicate it to your other group members.	17	2019-08-09 15:21:16	2019-08-09 15:21:16
152	This week I would like you to consider each assumption and have specific reasons for why they are being made. It is good practice to reflect on the validity of the assumptions with respect to the solution and think about how you could refine the model to make it more “real world”. It is this kind of reflection that we hope to see on your group exams, so it’s good to get into this habit. 	108	2019-08-09 15:29:56	2019-08-09 15:29:56
134	I know this is a unique class, with unique expectations, and disagreements are going to come up about the best way to solve the problems, but I’d like to see you use these disagreements to have a debate about the concepts, and the merits of both ideas. Just try to have fun with the class and be patient with the problems and your group, and I think you can excel in this class.	102	2019-08-09 15:03:03	2019-08-09 15:03:03
135	I know this is a unique class, with unique expectations, and disagreements are going to come up about the best way to solve the problems, but I’d like to see you use these disagreements to have a debate about the concepts, and the merits of both ideas. Just try to have fun with the class and be patient with the problems and your group, and I think you can excel in this class.	19	2019-08-09 15:03:14	2019-08-09 15:03:14
157	o\tYou are very good at explaining physics, so what I need now is to see you taking on a role that your group is still missing: the helper. As I said, ask your group members (e.g. someone who is strangely silent, someone who frequently asks for explanations) if they’re on track or if they can recount what was just calculated. Fact checks others’ ideas. You have the skills for it, I know you do.	60	2019-08-09 15:39:24	2019-08-09 15:39:24
158	You are very good at explaining physics, so what I need now is to see you taking on a role that your group is still missing: the helper. As I said, ask your group members (e.g. someone who is strangely silent, someone who frequently asks for explanations) if they’re on track or if they can recount what was just calculated. Fact check others’ ideas. You have the skills for it, I know you do.	106	2019-08-09 15:39:55	2019-08-09 15:39:55
136	I come around to talk to you all and I have asked you all to do something, like write an equation in variables or talk about something [insert your own example]. When I come back, none of you have done what I’ve asked. In the future, I’ll be less lenient about it, so be sure you’re paying attention to what I’m looking for you to work on. 	94	2019-08-09 15:07:01	2019-08-09 15:07:01
142	You act as an excellent facilitator between your group mates and make sure that you take everyone’s ideas into consideration. This leadership role is an important one for someone to take on and I feel that you would be a good fit as your enthusiasm helps encourage participation and is most likely one of the reasons why your group functions so well together.	105	2019-08-09 15:17:17	2019-08-09 15:17:17
156	It can be little unnerving answering questions if you aren’t confident in your answer, but being willing to answer those questions is a great way to build you an individual understanding of the material. You won’t be marked down for not being completely right on an answer, as long as you’re willing to learn!	111	2019-08-09 15:35:46	2019-08-09 15:35:46
137	Just because someone else seems to be taking initiative when problem-solving, that doesn’t mean that you have to sit idly by and wait for them to finish. There were times where [insert example]. If everyone, including you, attempts it, I guarantee that the answer you’re all looking for will be found faster. 	99	2019-08-09 15:08:59	2019-08-09 15:08:59
145	It is great that you have this understanding, but with good understanding becomes the responsibility to communicate it to your other group members.	10	2019-08-09 15:21:47	2019-08-09 15:21:47
146	Make sure to think big picture and try and connect ideas and when studying for the exam I would encourage you to go over all of the problems we have done and make sure you can set up the start of the problem, you don’t have to solve it all but checking you can set them up would help prepare you for the exam.	67	2019-08-09 15:22:50	2019-08-09 15:22:50
149	You could improve by starting to encourage your group members to be more involved with you in the problem. For example, you could set up the equation and ask another group member to perform the calculations. Or, you could help another group member set up the equation and help with the calculation portion. It’s important to make sure that all group members are involved thoroughly.	107	2019-08-09 15:26:24	2019-08-09 15:26:24
155	It can be little unnerving answering questions if you aren’t confident in your answer, but being willing to answer those questions is a great way to build you an individual understanding of the material. You won’t be marked down for not being completely right on an answer, as long as you’re willing to learn!	110	2019-08-09 15:34:25	2019-08-09 15:34:25
138	When the exam comes around, you won’t have the luxury of time to allow your group members to go about their own work and for you to wait for the answer to come. Make yourself a part of the process by going through the equations yourself, rewriting them, putting them on the quadrants, anything that gets you in the process and tells me you’re not a spectator.	103	2019-08-09 15:12:01	2019-08-09 15:12:01
139	When the exam comes around, you won’t have the luxury of time to allow your group members to go about their own work and for you to wait for the answer to come. Make yourself a part of the process by going through the equations yourself, rewriting them, putting them on the quadrants, anything that gets you in the process and tells me you’re not a spectator.	80	2019-08-09 15:12:35	2019-08-09 15:12:35
147	You could improve by starting to encourage your group members to be more involved with you in the problem. For example, you could set up the equation and ask another group member to perform the calculations. Or, you could help another group member set up the equation and help with the calculation portion. It’s important to make sure that all group members are involved thoroughly.	78	2019-08-09 15:23:45	2019-08-09 15:23:45
148	For next week, I think you could improve by starting to encourage your group members to be more involved with you in the problem. For example, you could set up the equation and ask another group member to perform the calculations. Or, you could help another group member set up the equation and help with the calculation portion. It’s important to make sure that all group members are involved thoroughly.	63	2019-08-09 15:25:29	2019-08-09 15:25:29
140	You can’t rely on your group members for the individual exam, you know; when it comes to testing yourself and what you know, you have to be well studied and put together for the day. If you don’t know certain concepts immediatly, that’s fine, but there’s a reason that you were unfamiliar with its properties. You can always benefit from bringing in hand-written notes for class since you can use them as a resource for information and use them as a study tool for the exam. 	104	2019-08-09 15:14:58	2019-08-09 15:14:58
150	Next week I would really like to see you write out work on the whiteboard. On the Individual Exam, you're going to have to be the one that makes decisions without being able to ask your group members, so, the more practice you get the better. For example, you could offer to write out the equations that you read about in the lecture notes, or you could help out whoever is performing the calculations -- or even better, offer to do the calculations yourself	104	2019-08-09 15:27:24	2019-08-09 15:27:24
153	I would like you to consider each assumption and have specific reasons for why they are being made. It is good practice to reflect on the validity of the assumptions with respect to the solution and think about how you could refine the model to make it more “real world”. It is this kind of reflection that we hope to see on your group exams, so it’s good to get into this habit. 	109	2019-08-09 15:32:12	2019-08-09 15:32:12
154	There a lot of different ideas being presented in the group so go ahead and be critical of them. While I don’t mean “criticize” the ideas, explore them critically and discuss how you think it could work or what may end up being problematic. I think that this discussion and keeping an eye on the assumptions will help your group come to a conclusion more efficiently.	76	2019-08-09 15:33:07	2019-08-09 15:33:07
159	You and your group had it pretty easy this week, so I hope you liked leaving early. However, don’t expect that for long! As I said, we’re going to focus more on fully understanding the problem rather than getting it done. 	86	2019-08-09 15:40:50	2019-08-09 15:40:50
162	It is usually a good idea to designate roles in your group. Someone could manage the 4-quadrants, another could look up notes on the computer, and the others could be writing out the math and solving the calculations. If you hit a roadblock, try to salvage your work and make sense of the physics that you have chosen to utilize, rather than erasing it all and starting from the beginning. 	112	2019-08-12 14:44:17	2019-08-12 14:44:17
163	It's helpful if you went through the homework problems and made sure that you were at least able to correctly set up the math in each of the problems. (exam 1) Additionally, it is usually helpful to draw a free body diagram and label all of the forces acting on the body. Think about how these forces can relate to acceleration and other net force equations. 	112	2019-08-12 14:46:09	2019-08-12 14:46:09
164	A general remark concerning late arrivals and absence. If you can't make it to class, I would appreciate a notice sent to either me or one of your group members. Handing in a doctor's certificate in case of illness will avoid a zero score for the day of absence. Please avoid arriving too late to class, since this typically has a negative impact on the group's focus. In the future, late arrival will be reflected in the individual's group focus score. 	83	2019-08-12 14:47:22	2019-08-12 14:47:22
165	This upcoming week, instead of working on your idea and making sure it works out before sharing it with the group, suggest it to the group, and explain to them why you want to try it. Then you can all work on solving it together, and other members of the group get more practice solving the problems. 	113	2019-08-12 14:50:38	2019-08-12 14:50:38
166	Instead of working on your idea and making sure it works out before sharing it with the group, suggest it to the group, and explain to them why you want to try it. Then you can all work on solving it together, and other members of the group get more practice solving the problems. 	114	2019-08-12 14:53:16	2019-08-12 14:53:16
167	If your equation is v = v + at, keep all of those v’s and a’s and t’s in there and do not plug any numbers in at all until you feel like your equation has been simplified or correctly set equal to another variable. This is the problem with just plugging in a bunch of numbers – it doesn’t tell you which variables become unimportant or which ones end up mattering the most	115	2019-08-12 14:57:12	2019-08-12 14:57:12
168	I know sometimes I ask you all to  ‘solve it in variables’. What I mean is, if your equation is v = v + at, keep all of those v’s and a’s and t’s in there and do not plug any numbers in at all until you feel like your equation has been simplified or correctly set equal to another variable. This is the problem with just plugging in a bunch of numbers – it doesn’t tell you which variables become unimportant or which ones end up mattering the most	44	2019-08-12 14:57:46	2019-08-12 14:57:53
170	During the group exam, you should come up with your plan in the first 10-15 minutes and stick with it even if you find your approach to be incorrect – just explain why your plan did not work out and what you could have done differently. Keep your four quadrants and the paper that you submit super organized and detailed – don’t leave anything out. 	112	2019-08-12 14:58:50	2019-08-12 14:58:50
171	Designating one person to do the write-up and remember; a solution is not just a number, but it is all the steps that you took to solve the problem clearly presented and discussed so that someone else could reproduce your solution using your method of execution. 	112	2019-08-12 14:59:53	2019-08-12 14:59:53
169	To ensure preparedness, make sure that you go over the practice exam and get familiar with your equation sheet. It is important to make sure that you understand how everything relates (like velocity and momentum, force and acceleration, etc.)	112	2019-08-12 14:58:28	2019-08-12 15:00:05
172	If you discover partway through the exam you made a mistake in your solution don’t go back and fix it, just explain the mistake and how you would fix it. We want to see you demonstrate your understanding of the physics concepts. 	112	2019-08-12 15:01:52	2019-08-12 15:01:52
173	I know a lot of groups have found it a great help to open up the grading scheme for the exam (which is on Webassign) just to make sure they are ticking all the boxes. 	112	2019-08-12 15:02:24	2019-08-12 15:02:24
174	I’d like you to involve more group members in your solving processes. It’s always good to have someone double-checking your work and could help them come to some of their own conclusions. For example, if you seem to be getting ridiculous numbers, ask one of the other people in your group if they can go through it with you and see where you might’ve gotten lost. Or, if you set up the problem with variables, ask someone else to plug in the numbers. 	107	2019-08-12 15:04:36	2019-08-12 15:04:36
175	 The structure of the class requires a little bit of devil’s advocacy to ensure that 1) everyone has agreed with a method and 2) the tutors can identify where a thought process has turned right or wrong. This will be important in the group exam – you might have an idea, and it could be a good idea and set of equations, but you need to be the first one to play devil’s advocate for your own ideas. Find some physics support for your equations and ideas (class notes, homework, previous problems) so that your methods become more infallible. 	116	2019-08-12 15:06:05	2019-08-12 15:06:05
176	The structure of the class requires a little bit of devil’s advocacy to ensure that 1) everyone has agreed with a method and 2) the tutors can identify where a thought process has turned right or wrong. This will be important in the group exam – you might have an idea, and it could be a good idea and set of equations, but you need to be the first one to play devil’s advocate for your own ideas. Find some physics support for your equations and ideas (class notes, homework, previous problems) so that your methods become more infallible. 	100	2019-08-12 15:06:29	2019-08-12 15:06:29
177	Instead of working on your idea and making sure it works out before sharing it with the group, suggest it to the group, and explain to them why you want to try it. Then you can all work on solving it together, and other members of the group get more practice solving the problems. 	113	2019-08-12 15:08:07	2019-08-12 15:08:07
178	For studying, go through the practice exam and, as you do the problems, identify on the equation sheet which equations you think are used in the problems. Finish the practice with that, and then on the solution sheet, see if your method and equations match up to theirs. It’s worth it to mention that there is more than one method of solving physics problems, so long as your method is proven by concept to work. 	112	2019-08-12 15:08:43	2019-08-12 15:09:04
179	Make sure you’re giving your group members an opportunity to share their ideas. Due to your good understanding, you sometimes tend to take over the group a bit, and others might not feel comfortable adding ideas, so make sure you’re encouraging everyone to add in during the discussion.	107	2019-08-13 13:56:49	2019-08-13 13:56:49
181	Try to play the role of “devil’s advocate” where you challenge the thoughts of your other group members. It seemed like you were always the one to catch the mistakes made by your other group members and this is a great strength that you should continue to utilize. 	117	2019-08-13 14:00:39	2019-08-13 14:01:55
185	You need to be reading the notes before coming into class, and you also know when homework is due by. Space out blocks of time when you can work on the homework and read through the notes and I guarantee it will get easier to offer ideas in class and get through that homework. 	120	2019-08-13 14:18:35	2019-08-13 14:18:35
190	You have good ideas, and I really think your next group will be missing out if you don’t share them. 	121	2019-08-13 14:57:49	2019-08-13 14:57:49
196	Don’t be afraid to ask your group to slow down or explain their reasoning. It did not look like it was just you, the main improvement your group needs to make is communication. I would suggest trying to be sort of a devil’s advocate: question things; make sure that every idea is discussed and there is reasoning behind choosing certain ideas. Doing this will benefit your and the groups understanding, and make sure everyone is on the same page.	22	2019-08-14 14:27:23	2019-08-14 14:27:23
199	I want you to initiate the set-up of mathematics more. Some of your other group members seemed to be doing a lot of the heavy lifting when it comes to working through the math, and I’ve asked them to give you more of a chance to work on the set-up for yourself. This will be beneficial in the long run because setting up the math equations is probably the most important part of solving for the problems and getting a good understanding of the material.	103	2019-08-14 14:43:41	2019-08-14 14:43:41
203	Be careful not to overpower the others in your group with the speed of your thought processes. I found myself struggling to put together your line of thinking when you explained to me because you put a lot of connections together at once. Your group (and I) needs to be taken through those connections at a slower pace sometimes so that they understand what you are doing and not just saying that they do. 	106	2019-08-14 14:51:54	2019-08-14 14:51:54
205	Next week, I want to see your voice become more prominent in the group. For example, you can ask your group member the same questions you’d ask me. You can also make sure that the group knows exactly what they’re lacking and what they’re solving for as you seem to be good at that already! 	107	2019-08-14 14:59:13	2019-08-14 14:59:13
210	If you guys find yourselves getting stuck or want some good talking points to base your discussion off of, check the learning objectives before or as you start working through the problem. This will direct your group in the right path and hopefully spark some good discussion. 	131	2019-08-15 14:09:12	2019-08-15 14:09:12
211	When you make assumptions, make sure you justify those assumptions and discuss how the model would change if you took those assumptions away. For example, a common assumption is no air resistance, so how would the model change if there was air resistance?	109	2019-08-15 14:18:47	2019-08-15 14:18:47
214	Part of that leadership is making sure that everyone's ideas are promoted. I want you to try and make sure any ideas from other group members are brought in and discussed by the group. This level of discussion will result in confronting non-uniform ideas and result in a better conceptual understanding.	78	2019-08-15 14:44:45	2019-08-15 14:44:45
180	Make sure you’re giving your group members an opportunity to share their ideas. Due to your good understanding, you sometimes tend to take over the group a bit, and others might not feel comfortable adding ideas, so make sure you’re encouraging everyone to add during the discussion.	100	2019-08-13 13:57:12	2019-08-13 13:57:12
182	You guys always solve the problem quickly, but that’s not necessarily what the class sessions are about. This class is based on cooperative learning with your peers, and you may find it beneficial to try discussing the physics concepts of the session while keeping the notes and learning goals in mind. 	38	2019-08-13 14:03:19	2019-08-13 14:03:19
215	A solution is not just a number, but it is all the steps that you took to solve the problem clearly presented and discussed so that someone else could reproduce your solution using your method of execution. If you feel that you sometimes have a hard time setting up these problems on your own, following this guideline may help. First, draw out exactly what is happening in the problem. Then, define your system and decide whether or not energy/momentum can be conserved. If they can, write down the equations Ei=Ef and pi=pf and include all initial and final energies and momentums. If you have more than one unknown, look for other equations including the unknowns that you can plug into the original equations 	112	2019-08-16 14:56:51	2019-08-16 14:56:51
183	Keep the learning goals in mind when you are solving the problem. This will help to simplify the methods that you choose to use when solving the problem. 	118	2019-08-13 14:08:04	2019-08-13 14:08:10
186	In your next group, it would be good for you to demonstrate early on that you are well suited to take on a leadership role as your ideas and explanations are imperative to the group’s understanding of the problem. 	121	2019-08-13 14:25:46	2019-08-13 14:25:46
188	One thing to take into consideration is that in your next group, you may not have teammates who are quite as up to speed as you are, so it is important that you stop and take the time to check for everyone’s understanding before continuing on in the problem.	122	2019-08-13 14:34:21	2019-08-13 14:34:21
198	You are already Initiating discussion and carrying out the calculations which are great but try to get your other group members to set up the equations themselves before you write them out yourself. You may find that they have a less refined understanding of the material than it seems. I’m worried that some members of your group may be ‘following along’ without actually being able to start the problem up correctly themselves. 	97	2019-08-14 14:41:22	2019-08-14 14:41:22
204	I would greatly appreciate you extending a lot of patience to [student name] as it seems as though they struggle with staying focused. One aspect you all can contribute to this focus is making sure to ask their opinion and involve him as much as possible. I will, of course, push them to stay focused as well but I would appreciate your help. 	128	2019-08-14 14:55:19	2019-08-14 14:55:19
206	 Making sure you write out every step and keeping it in variables until the end can help you avoid making mistakes. Also, it is much easier for us to give you partial credit when we grade the individual exam because we can really see your thought processes.	129	2019-08-15 14:03:36	2019-08-15 14:03:36
207	Making sure you write out every step and keeping it in variables until the end can help you avoid making mistakes. Also, it is much easier for us to give you partial credit when we grade the individual exam because we can really see your thought processes.	130	2019-08-15 14:04:44	2019-08-15 14:04:44
184	This is the kind of atmosphere you want in your groups, focus on this kind of atmosphere in your upcoming group, as it will be very beneficial. 	119	2019-08-13 14:10:03	2019-08-13 14:10:03
187	You act as a wonderful facilitator of discussion between your group members and constantly make sure that everyone in your group is included in the discussion – both of which will be important to carry into your next group as well	121	2019-08-13 14:29:57	2019-08-13 14:29:57
192	 You’ll have to gauge how talkative or in-depth your new group members seem to be, but I definitely hope you find that balance between self-contribution and teamwork that you’ve found here. 	122	2019-08-13 15:02:17	2019-08-13 15:02:17
194	A very important part of physics, in general, is to ask yourself why. Why am I calculating this and what does this help me solve in the problem? Asking yourself these questions will keep your group on the right track, as well as bettering your problem-solving techniques 	125	2019-08-14 14:17:22	2019-08-14 14:17:22
189	A decent homework grade added to in-class grade can make passing the class very feasible even if the exams don’t go well. Also, making sure to put the time in preparing for class, this means, reading the notes or watching the videos and taking your own summation notes will help contribute to your success in the future exams. Starting the week off strong is easily the first stepping stone to being able to answer the post-class homework questions at the end of the week. 	123	2019-08-13 14:52:24	2019-08-13 14:52:24
191	Your group members count on you to suggest ideas as well as working through the calculations, you are a team working towards a common goal. Even if you think your ideas are incorrect, find out why and discuss with your group. This will improve your understanding of physics.	29	2019-08-13 14:59:07	2019-08-13 14:59:07
193	A very important part of physics, in general, is to ask yourself why. Why am I calculating this and what does this help me solve in the problem? Asking yourself these questions will keep your group on the right track, as well as bettering your problem-solving techniques.	124	2019-08-14 14:15:57	2019-08-14 14:15:57
195	Don’t be afraid to ask your group to slow down or explain their reasoning. It did not look like it was just you, the main improvement your group needs to make is communication. I would suggest trying to be sort of a devil’s advocate: question things; make sure that every idea is discussed and there is reasoning behind choosing certain ideas. Doing this will benefit your and the groups understanding, and make sure everyone is on the same page.	126	2019-08-14 14:22:51	2019-08-14 14:25:50
197	As this was your first time in your new groups and everyone is still settling into their new roles, there may be some fluctuation in your grades from your previous group scores. While this may seem disconcerting, as long as you listen to my feedback and continue to demonstrate your physics understanding, you will see a rise in your grades over the following weeks. 	127	2019-08-14 14:36:44	2019-08-14 14:36:44
200	To make sure everyone in your group practices discussing physics, you could take turns to have someone explain and reflect (parts of) your plan or results to the rest of the group. 	93	2019-08-14 14:49:26	2019-08-14 14:49:26
202	Be careful not to overpower the others in your group with the speed of your thought processes. I found myself struggling to put together your line of thinking when you explained to me because you put a lot of connections together at once. Your group (and I) needs to be taken through those connections at a slower pace sometimes so that they understand what you are doing and not just saying that they do. 	100	2019-08-14 14:51:29	2019-08-14 14:51:29
209	If you guys find yourselves getting stuck or want some good talking points to base your discussion off of, check the learning objectives before or as you start working through the problem. This will direct your group in the right path and hopefully spark some good discussion. 	79	2019-08-15 14:08:18	2019-08-15 14:08:18
213	 I want you speaking up a little more with the tutor questions so that I can make sure that you’re gaining a good understanding of the concepts. This doesn’t necessarily mean that I expect you to know the answer to every question, but I’d like to see you contributing when the group is trying to come up with an answer, or asking questions about their answers. 	132	2019-08-15 14:35:33	2019-08-15 14:35:33
201	To make sure everyone in your group practices discussing physics, you could take turns to have someone explain and reflect (parts of) your plan or results to the rest of the group. 	109	2019-08-14 14:50:23	2019-08-14 14:50:23
208	If you guys find yourselves getting stuck or want some good talking points to base your discussion off of, check the learning objectives before or as you start working through the problem. This will direct your group in the right path and hopefully spark some good discussion. 	76	2019-08-15 14:07:55	2019-08-15 14:07:55
212	When you make assumptions, make sure you justify those assumptions and discuss how the model would change if you took those assumptions away. For example, a common assumption is no air resistance, so how would the model change if there was air resistance?	108	2019-08-15 14:21:36	2019-08-15 14:21:36
216	A solution is not just a number, but it is all the steps that you took to solve the problem clearly presented and discussed so that someone else could reproduce your solution using your method of execution. If you feel that you sometimes have a hard time setting up these problems on your own, following this guideline may help. First, draw out exactly what is happening in the problem. Then, define your system and decide whether or not energy/momentum can be conserved. If they can, write down the equations Ei=Ef and pi=pf and include all initial and final energies and momentums. If you have more than one unknown, look for other equations including the unknowns that you can plug into the original equations 	79	2019-08-16 15:03:15	2019-08-16 15:03:15
217	A solution is not just a number, but it is all the steps that you took to solve the problem clearly presented and discussed so that someone else could reproduce your solution using your method of execution. If you feel that you sometimes have a hard time setting up these problems on your own, following this guideline may help. First, draw out exactly what is happening in the problem. Then, define your system and decide whether or not energy/momentum can be conserved. If they can, write down the equations Ei=Ef and pi=pf and include all initial and final energies and momentums. If you have more than one unknown, look for other equations including the unknowns that you can plug into the original equations 	125	2019-08-16 15:04:10	2019-08-16 15:04:10
218	Not everyone was working on the same part of the problem which didn't benefit the group and individual understanding. This is because it took a lot of time to catch the group up on what people were doing separately. So, this upcoming week make sure you all work as a group to get a plan and solve for the problem. A Great way to do this is to focus on finding one thing at a time and specifically sticking to that idea. 	49	2019-08-16 15:22:46	2019-08-16 15:22:46
219	For next week, I want you to keep doing as minimal solution writing as possible and be really focused on just writing down the pieces and having the rest of the group put them together. One way to do this would be by drawing a diagram and then labeling at what points we can use certain concepts. You can write down the equations we’ll be using and talk about what each of the variables represents. Basically, you should be talking through everything you’re writing down so the whole group can follow along easily and contribute their individual ideas. 	107	2019-08-16 15:29:48	2019-08-16 15:29:48
220	Check-in with your group members as you're going along with the problem. For example, when the group has decided on a certain solution, make sure everyone understands why that's the solution and why it's a good idea. Or, when you're about to plug in the numbers, go through the problem once more with the whole group to make sure everyone would be able to do it on their own. This will assist their learning as well as your own since it challenges you to explain the concepts you're applying. 	106	2019-08-16 15:31:27	2019-08-16 15:31:27
221	Check-in with your group members as you're going along with the problem. For example, when the group has decided on a certain solution, make sure everyone understands why that's the solution and why it's a good idea. Or, when you're about to plug in the numbers, go through the problem once more with the whole group to make sure everyone would be able to do it on their own. This will assist their learning as well as your own since it challenges you to explain the concepts you're applying. 	49	2019-08-16 15:36:04	2019-08-16 15:36:04
222	 try to actually do your problems in class as if your boards were to be graded like a group exam.	133	2019-08-20 12:41:56	2019-08-20 12:41:56
223	Don’t be afraid to review someone else’s work and let them know your thoughts on it you will find that this will aide the entire group's understanding of the concepts	111	2019-08-20 12:49:40	2019-08-20 12:49:40
224	You should reconsider your strategy as just doing the work necessary to finish the problem will not lead to a sufficient understanding of the complex topics involved in the course	134	2019-08-20 12:59:49	2019-08-20 12:59:49
225	In the future when you have a question raise your hand and I'll come over. This way your group gets to be part of the conversation and benefit from it as well	135	2019-08-20 13:03:13	2019-08-20 13:03:52
226	This is an important skill to maintain and develop as in Physics many topics build off one another	136	2019-08-20 13:12:16	2019-08-20 13:12:16
227	Don’t hesitate to pitch an idea if you aren’t entirely sure how it will fit into the problem. Sometimes just mentioning it will cause someone else to think of a related idea that will eventually circle around to the right direction, but all that is needed is the initial push.	137	2019-08-20 13:15:16	2019-08-20 13:15:16
\.


--
-- Data for Name: grades; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.grades (id, score, note, category_id, draft_id, inserted_at, updated_at) FROM stdin;
1	100	\N	49	1	2019-07-25 04:04:21	2019-07-25 04:04:21
2	100	\N	50	1	2019-07-25 04:04:21	2019-07-25 04:04:21
3	100	\N	53	1	2019-07-25 04:04:21	2019-07-25 04:04:21
4	100	\N	42	1	2019-07-25 04:04:21	2019-07-25 04:04:21
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.notifications (id, content, seen, draft_id, user_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: observations; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.observations (id, content, type, category_id, inserted_at, updated_at) FROM stdin;
1	Explaining work/ solution to group after the problem is completed.	positive	5	2019-06-25 05:32:15	2019-06-25 05:32:15
2	Not writing out work on white boards	negative	5	2019-06-25 05:32:15	2019-06-25 05:32:15
3	not checking in to ensure whole group is on the same page	negative	5	2019-06-25 05:32:15	2019-06-25 05:32:15
4	 not explaining ideas to group	neutral	5	2019-06-25 05:32:15	2019-06-25 05:32:15
5	only explaining ideas to group when in disagreement	neutral	5	2019-06-25 05:32:15	2019-06-25 05:32:15
6	some people left out of explanations	neutral	5	2019-06-25 05:32:15	2019-06-25 05:32:15
8	Explaining work/ solution to group after the problem is completed.	positive	55	2019-07-10 18:16:25	2019-07-10 18:16:25
9	Not writing out work on white boards	negative	55	2019-07-10 18:17:07	2019-07-10 18:17:07
10	not checking in to ensure whole group is on the same page	negative	55	2019-07-10 18:17:24	2019-07-10 18:17:24
12	only explaining ideas to group when in disagreement	negative	55	2019-07-10 18:18:12	2019-07-10 18:18:12
13	some people left out of explanations	negative	55	2019-07-10 18:18:27	2019-07-10 18:18:27
14	not sharing ideas	negative	55	2019-07-10 18:42:53	2019-07-10 18:42:53
15	make sure you take notes prior to coming to class this improve your ability to spend class time more effectively on the topics	negative	83	2019-07-10 18:49:17	2019-07-10 18:49:17
16	it is important to write out the math in addition to your contributions to the discussion	negative	87	2019-07-10 18:52:14	2019-07-10 18:52:14
17	having prior experience	positive	55	2019-07-10 18:53:48	2019-07-10 18:53:48
18	Student only asks the tutor questions.	negative	56	2019-07-10 18:55:27	2019-07-10 18:55:27
19	Becoming frustrated with the project	neutral	74	2019-07-10 18:56:57	2019-07-10 18:56:57
20	your group understanding score could use some improvement.	neutral	64	2019-07-11 00:10:41	2019-07-11 00:10:41
21	you did well to update the quadrants board for your group, and you referenced this throughout the problem	positive	94	2019-07-11 00:13:08	2019-07-11 00:13:08
22	While you were visibly engaged with the problem, it was difficult for me to gauge what you were thinking and where your understanding of the problem was at.	neutral	72	2019-07-11 00:15:42	2019-07-11 00:15:42
23	 make sure that your ideas and questions are being addressed by the group	negative	91	2019-07-11 00:19:02	2019-07-11 00:19:02
24	Great job explaining to your group the algebraic solution to the second part of the problem!	positive	55	2019-07-11 00:20:39	2019-07-11 00:20:39
25	you seemed very focused on just solving the problem. 	neutral	84	2019-07-18 12:10:50	2019-07-18 12:10:50
26	I liked what I saw this week in terms of you contributing to the group understanding.	positive	97	2019-07-18 12:13:00	2019-07-18 12:13:00
27	I saw you make the connections fairly quickly	positive	99	2019-07-18 12:15:19	2019-07-18 12:15:19
28	I want to say I could definitely tell you read the feedback from last week	positive	82	2019-07-18 12:17:38	2019-07-18 12:17:38
29	I’d like to see you to continue improving how you contribute to the group dynamic	negative	72	2019-07-18 12:19:45	2019-07-18 12:19:45
30	Empty assumptions	negative	94	2019-07-18 12:23:08	2019-07-18 12:23:08
31	Empty quadrant board	negative	94	2019-07-18 12:25:47	2019-07-18 12:25:47
32	Struggling with no use of learning goals	neutral	83	2019-07-18 12:30:43	2019-07-18 12:30:43
33	Not stating/ cementing assumptions used	negative	65	2019-07-18 12:32:31	2019-07-18 12:32:31
34	 there was an instance where members had tried two differing methods in solving a problem.	negative	86	2019-07-18 12:39:42	2019-07-18 12:39:42
35	Not everyone coding	negative	58	2019-07-18 12:47:15	2019-07-18 12:47:15
36	this week you did a great job of really showing your ideas.	positive	97	2019-07-18 12:49:13	2019-07-18 12:49:13
37	I could tell that although you were familiar with the material, you had not reviewed it prior to class	negative	83	2019-07-18 12:51:25	2019-07-18 12:51:25
38	 I still noticed that you really wanted to rush and finish the problem.	negative	84	2019-07-18 12:53:30	2019-07-18 12:53:30
39	when you kept trying to tell your group member that what they were doing was wrong Rather than explaining what was wrong with their idea.	negative	64	2019-07-18 12:55:57	2019-07-18 12:55:57
40	you did a good job this week showing your group members that coding isn’t so scary!	positive	58	2019-07-18 13:02:08	2019-07-18 13:02:08
41	you did a really excellent job of keeping up the momentum of your groups solution this week.	positive	72	2019-07-18 13:04:49	2019-07-18 13:04:49
42	something you all can start to work on is developing strategies to check your work	neutral	98	2019-07-18 13:08:21	2019-07-18 13:08:21
43	I notice that you are able to catch errors and to present them to the group due to your lack of prior experience in Physics\r\n	neutral	60	2019-07-18 13:30:18	2019-07-18 13:31:40
44	Your group doesn't work in variables	negative	85	2019-07-18 13:33:01	2019-07-18 13:33:01
45	Assumptions only dealing with surroundings rather than system	neutral	65	2019-07-18 13:43:38	2019-07-18 13:43:38
46	I really appreciate you being clear when something is difficult for you to understand.	positive	72	2019-07-18 13:50:04	2019-07-18 13:50:04
47	I noticed that although you participated well in the group discussion, when it came to writing your ideas on the whiteboard you struggled	negative	87	2019-07-18 13:53:41	2019-07-18 13:53:41
48	One person does a majority of the coding	negative	58	2019-07-18 13:56:52	2019-07-18 13:56:52
49	The main thing I would like to see you all work on as a group is to make sure and listen to each other’s ideas and to come to a consensus view on how to proceed with solving the problem	neutral	64	2019-07-18 15:07:57	2019-07-18 15:07:57
50	Group members are working on their own	negative	66	2019-07-24 16:13:40	2019-07-24 16:13:40
51	this week I saw you working through a lot of them math, which was great to see.	neutral	81	2019-07-24 16:17:56	2019-07-24 16:17:56
52	I've noticed recently that when your group gets hung up you are usually the first to propose a solution	neutral	67	2019-07-27 19:46:30	2019-07-27 19:46:30
53	Your group has typically taken the approach of just trying a lot of different methods to solve the problem instead of more carefully considering the options you have.	neutral	77	2019-07-27 19:50:17	2019-07-27 19:50:17
54	I noticed that you sometimes back down on your ideas.	negative	60	2019-07-28 10:14:36	2019-07-28 10:14:36
55	The group really expressed a want to leave or wanted me to give the answer so they could leave.	negative	103	2019-07-28 10:26:48	2019-07-28 10:26:48
56	 I have noticed that during problems that you get lost but don’t tell your group or allow them to move on.	negative	55	2019-07-28 10:31:16	2019-07-28 10:31:16
57	This week the group did a nice job of working on getting some evidence for your plans.	positive	77	2019-07-28 10:45:08	2019-07-28 10:45:08
58	you did a nice job this week stepping back and allowing your group members more space to flesh out their ideas and work them out. Specifically, with the coding.	positive	58	2019-07-28 11:00:25	2019-07-28 11:00:25
59	the group rushed through the problem	negative	103	2019-07-28 11:13:26	2019-07-28 11:13:26
60	You have a lot of great qualities as a facilitator of a group	positive	97	2019-07-28 11:18:39	2019-07-28 11:18:39
61	you seemed to have a lot of difficulty understanding the code	neutral	58	2019-07-28 13:02:59	2019-07-28 13:02:59
62	when I come over, you take the lead on your group’s explanation almost every time.	negative	96	2019-07-28 13:07:45	2019-07-28 13:07:45
65	This week, I saw a few notes on the quadrants board regarding the.......	neutral	94	2019-07-31 15:18:29	2019-07-31 15:18:29
78	The student seems to take on a leadership role, and you want them to encourage other members to participate more	neutral	96	2019-08-07 14:39:18	2019-08-07 14:39:18
84	Students are not all writing down their solutions on the board. 	neutral	110	2019-08-08 14:28:31	2019-08-08 14:28:31
86	The group is moving incredibly fast...	neutral	110	2019-08-08 14:53:13	2019-08-08 14:53:13
91	The student is helping explain concepts to members that don't understand...	positive	64	2019-08-08 15:18:23	2019-08-08 15:18:23
96	The student is doing more coding but is not coding enough due to inexperience.	neutral	58	2019-08-09 14:20:11	2019-08-09 14:20:11
101	The student has physics experience and is introducing new concepts	negative	62	2019-08-09 14:59:13	2019-08-09 14:59:26
63	it seemed like you were the only one to work through the calculations	negative	81	2019-07-31 14:09:33	2019-07-31 14:09:33
64	 After some discussion on key components, your team was able to develop a plan on both days to successfully model the physics	neutral	77	2019-07-31 14:56:09	2019-07-31 14:56:09
70	When your group member was late I noticed your group taking the time to catch them up to speed.	positive	55	2019-08-01 14:06:47	2019-08-01 14:06:47
74	The group is not using the board as much as they should...	neutral	94	2019-08-07 14:17:49	2019-08-07 14:17:49
79	The group is planning, but either the planning is unorganized or they are skipping crucial steps	neutral	77	2019-08-07 14:56:11	2019-08-07 14:56:11
95	The student does not ask the group questions, instead, they rely on the LA for answers.	negative	86	2019-08-09 14:11:37	2019-08-09 14:11:37
66	 I’ve noticed that often it seems as though disagreements aren’t being vocalized	negative	60	2019-07-31 15:22:47	2019-07-31 15:22:47
67	For next week, as the exam is coming up, I recommend that you guys try and focus on organization and building from equations.	neutral	101	2019-07-31 15:37:27	2019-07-31 15:37:27
82	Students are getting answers but do note use notes to justify their ideas.	neutral	110	2019-08-07 15:24:28	2019-08-07 15:24:28
83	Students are leaving in the middle of class, and/or consistently late	negative	71	2019-08-08 14:07:41	2019-08-08 14:07:41
90	The student does not do homework and is clearly affecting their performance in class.	negative	93	2019-08-08 15:07:11	2019-08-08 15:07:11
93	One person understands the concepts the most out of all the group members.	neutral	64	2019-08-08 15:30:32	2019-08-08 15:30:32
68	 I would like to remind you that it is important to stay off your phone during the class period	negative	79	2019-07-31 15:38:45	2019-07-31 15:38:45
69	Your group does a good job coming up with a reasoned solution, but I notice there aren't many alternative paths that are explored.	neutral	99	2019-08-01 14:03:52	2019-08-01 14:03:52
89	The student did a better job at allowing others to code but is still at time hogging the computer.	neutral	58	2019-08-08 15:05:50	2019-08-08 15:05:50
97	The student seems like a good facilitator but is doing a bulk of the work.	neutral	97	2019-08-09 14:26:58	2019-08-09 14:26:58
71	The group is not sharing ideas with one another, leading to difficulty in solving the problem or other issues.	negative	67	2019-08-07 13:52:47	2019-08-07 13:52:47
72	Students are getting stuck, not knowing what to do next, but are not sharing ideas to move forward.	neutral	86	2019-08-07 13:59:50	2019-08-07 13:59:50
73	Students collaborate well and all participate, but the discussions can be a little more balanced. 	neutral	66	2019-08-07 14:05:33	2019-08-07 14:05:33
75	An individual student is having some trouble contributing their ideas to the group...	negative	66	2019-08-07 14:20:50	2019-08-07 14:20:50
76	The group is having some trouble making a consensus	neutral	77	2019-08-07 14:25:07	2019-08-07 14:25:07
80	The student does not contribute their original ideas with the group. Instead, they rely heavily on their group for answers.	negative	86	2019-08-07 15:06:45	2019-08-07 15:06:45
81	Is sharing ideas, even if the ideas are incorrect	positive	67	2019-08-07 15:09:25	2019-08-07 15:09:25
92	The student is not afraid to disagree with the group, and it benefits discussion...	positive	60	2019-08-08 15:24:34	2019-08-08 15:24:34
98	Not making detailed figures/ representations 	neutral	61	2019-08-09 14:29:36	2019-08-09 14:29:36
77	The student is not sharing ideas with the group, thus hindering the group's ability to problem-solve.	negative	87	2019-08-07 14:35:10	2019-08-07 14:35:10
85	Student(s) are too concerned about their grades or performance in class and are afraid to ask questions,	negative	104	2019-08-08 14:34:43	2019-08-08 14:34:43
88	The student is sharing ideas but isn't actively applying them with their group	neutral	67	2019-08-08 15:00:14	2019-08-08 15:00:14
94	Student lacks focus and does not participate.	negative	79	2019-08-08 15:39:29	2019-08-08 15:39:29
99	One student is doing the work and is not checking other group member's ideas	neutral	81	2019-08-09 14:46:06	2019-08-09 14:46:06
100	One student is doing all the work by not letting other group members participate	negative	81	2019-08-09 14:50:46	2019-08-09 14:50:46
102	Does not enjoy disagreements and discussions	negative	74	2019-08-09 15:02:41	2019-08-09 15:02:41
103	The student just waits for other group members to give them the answers.	negative	87	2019-08-09 15:11:51	2019-08-09 15:11:51
104	The student relies on their group and it is concerning due to the individual portion of the exam.	negative	101	2019-08-09 15:14:25	2019-08-09 15:14:25
105	The student can be or is a great leader	positive	96	2019-08-09 15:17:08	2019-08-09 15:17:08
106	One student has most of the understanding but does not explain anything to their peers.	neutral	110	2019-08-09 15:20:16	2019-08-09 15:20:16
107	One student is doing good work but could get their group a little more involved.	neutral	81	2019-08-09 15:26:06	2019-08-09 15:26:06
108	Students are already doing a good job but could improve 	neutral	98	2019-08-09 15:29:42	2019-08-09 15:29:42
109	Students have a good understanding but could improve.	neutral	114	2019-08-09 15:32:00	2019-08-09 15:32:00
110	Nervous about asking questions and participating	neutral	74	2019-08-09 15:34:05	2019-08-09 15:34:05
111	The student is nervous to share ideas	neutral	86	2019-08-09 15:35:25	2019-08-09 15:35:25
112	Testing tips	neutral	101	2019-08-12 14:44:03	2019-08-12 14:44:03
113	The student easily gives up on their ideas in favor of others without discussion 	negative	60	2019-08-12 14:49:46	2019-08-12 14:49:46
114	The student is not fully sharing their ideas with the group and tends to do work on their own.	negative	67	2019-08-12 14:52:59	2019-08-12 14:52:59
115	Not keeping equations in variables...	negative	63	2019-08-12 14:56:34	2019-08-12 14:56:34
116	The student doesn't like to be challenged	negative	99	2019-08-12 15:05:49	2019-08-12 15:05:49
117	The student challenges other's ideas and helps with discussion	positive	99	2019-08-13 14:00:29	2019-08-13 14:00:29
118	The group solve the problems but overcomplicates them.	neutral	77	2019-08-13 14:07:52	2019-08-13 14:07:52
119	The current group dynamic is good	positive	115	2019-08-13 14:09:51	2019-08-13 14:09:51
120	The student's lack of preparation hinders their discussion.	negative	83	2019-08-13 14:18:02	2019-08-13 14:18:02
121	Want them to take certain habits to their new groups.	positive	115	2019-08-13 14:25:13	2019-08-13 14:29:02
122	Things to consider in your new group.	neutral	115	2019-08-13 14:34:12	2019-08-13 14:34:12
123	The student didn't feel good about the exam	neutral	101	2019-08-13 14:50:38	2019-08-13 14:50:38
124	The student is not thinking about why they do what they do (plugging and chugging or guess and checking)	negative	84	2019-08-14 14:14:48	2019-08-14 14:14:48
125	The student is guessing and checking, and not understanding why they do things	negative	114	2019-08-14 14:17:07	2019-08-14 14:17:07
126	The student is having trouble taking part in the discussion, but could be an effective devil's advocate 	neutral	99	2019-08-14 14:22:26	2019-08-14 14:22:26
127	Grades	neutral	115	2019-08-14 14:36:24	2019-08-14 14:36:24
128	One student is falling behind	neutral	55	2019-08-14 14:54:27	2019-08-14 14:54:27
129	The student does not write out all the steps	neutral	63	2019-08-15 14:02:51	2019-08-15 14:02:51
130	The student is participating but is not writing out all the steps	neutral	87	2019-08-15 14:04:40	2019-08-15 14:04:40
131	The group gets stuck easily...	neutral	63	2019-08-15 14:09:07	2019-08-15 14:09:07
132	Not answering any tutor questions	negative	91	2019-08-15 14:35:04	2019-08-15 14:35:04
133	The students should improve the quality of their quadrants for the group exam	neutral	101	2019-08-20 12:41:18	2019-08-20 12:41:18
134	Student only contributes ideas when it will further the course of the problem	negative	66	2019-08-20 12:59:10	2019-08-20 12:59:10
135	The student comes over to the tutor to ask questions	neutral	56	2019-08-20 13:02:46	2019-08-20 13:02:46
136	The student is able to make meaningful connections between projects and concepts	positive	114	2019-08-20 13:11:48	2019-08-20 13:11:48
137	Student is having difficulty bringing up ideas in conflict to the current group plan	neutral	99	2019-08-20 13:14:51	2019-08-20 13:14:51
\.


--
-- Data for Name: password_credentials; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.password_credentials (user_id, password, inserted_at, updated_at) FROM stdin;
1	$pbkdf2-sha512$160000$wXwHb2IghUagRLscFN26PQ$O2Vt31qeJI6uo/K2topjTHZI5NZz1P.sVypI72d0WUykRtCKhUdi7r/Hd4dG2FNnO5GEvq1V10n.ZXVHkjmJBA	2019-06-24 17:18:19	2019-06-24 17:18:19
\.


--
-- Data for Name: password_resets; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.password_resets (user_id, token, expire, inserted_at, updated_at) FROM stdin;
9	K3KDGJ7GHUEOUAZ4NOG2FLOLZOESUCLSK7ZLJASTWFIAMXEYEF3Q====	2019-08-06 18:29:51	2019-08-05 18:29:51	2019-08-05 18:29:51
\.


--
-- Data for Name: review_request; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.review_request (draft_id, user_id) FROM stdin;
\.


--
-- Data for Name: rotation_group_users; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.rotation_group_users (rotation_group_id, user_id) FROM stdin;
2	1
2	2
2	5
\.


--
-- Data for Name: rotation_groups; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.rotation_groups (id, number, description, rotation_id, inserted_at, updated_at) FROM stdin;
1	1	Test rotation group	1	2019-06-25 05:32:14	2019-06-25 05:32:14
2	1	Group 1	2	2019-07-11 16:36:29	2019-07-11 16:36:29
\.


--
-- Data for Name: rotation_users; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.rotation_users (user_id, rotation_id) FROM stdin;
\.


--
-- Data for Name: rotations; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.rotations (id, number, description, start_date, end_date, section_id, inserted_at, updated_at) FROM stdin;
1	1	Test rotation	2019-01-05	2019-01-10	1	2019-06-25 05:32:14	2019-06-25 05:32:14
2	1	Group 1 - Student 1 - Student 2 - Student 3 - Student 4	2019-07-01	2019-08-01	2	2019-07-11 16:35:55	2019-07-19 16:24:17
3	1	This is Paul's group 1	2019-11-04	2019-12-04	3	2019-11-04 19:35:03	2019-11-04 19:35:03
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20181215234115	2019-06-24 17:17:59
20181215234124	2019-06-24 17:17:59
20181215234131	2019-06-24 17:17:59
20190428204831	2019-08-21 04:19:34
20190704031148	2019-08-21 04:19:34
20190729072940	2019-08-21 04:19:34
20190926060805	2019-10-21 16:32:02
20191002033451	2019-10-21 16:33:24
\.


--
-- Data for Name: section_users; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.section_users (user_id, section_id) FROM stdin;
\.


--
-- Data for Name: sections; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.sections (id, number, description, semester_id, inserted_at, updated_at, classroom_id) FROM stdin;
1	1	Test section	1	2019-06-25 05:32:14	2019-06-25 05:32:14	1
2	004	P-Cubed - Richard and Carlo	3	2019-07-11 16:34:06	2019-07-11 16:34:06	1
3	Section 003	P-Cubed	1	2019-11-04 19:33:09	2019-11-04 19:33:09	2
\.


--
-- Data for Name: semester_users; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.semester_users (user_id, semester_id) FROM stdin;
\.


--
-- Data for Name: semesters; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.semesters (id, name, description, start_date, end_date, inserted_at, updated_at) FROM stdin;
1	Spring Semester	Test semester	2019-01-01	2019-05-01	2019-06-25 05:32:14	2019-06-25 05:32:14
2	Fall Semester	Test semester	2018-09-01	2018-12-01	2019-06-25 05:32:14	2019-06-25 05:32:14
3	Fall2019	Fall 2019 - pilot use of Feedback App - P-Cubed	2019-08-27	2019-12-31	2019-06-27 18:18:59	2019-06-27 18:18:59
\.


--
-- Data for Name: student_explanations; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.student_explanations (id, draft_id, feedback_id, explanation_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: student_feedback; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.student_feedback (id, draft_id, feedback_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: token_credentials; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.token_credentials (token, expire, user_id, inserted_at, updated_at) FROM stdin;
6GFUQJP7BK2OUJK5HUE6TFJD4CIEAMWYCHBMUKCQ55ICNCWTDILA====	2019-07-12 16:29:41	3	2019-07-11 16:29:41	2019-07-11 16:29:41
2TLVSVOBIM2JRKEQUK2NEKCDD7RTHGDV3IJTV6VVKQT7YZV2DDTA====	2019-07-12 16:29:58	3	2019-07-11 16:29:58	2019-07-11 16:29:58
76ZZBB46ZQUM64LDNZQKT4D67EKFDOBLTZNMHB7H3Q3I67VLMNNA====	2019-07-20 16:23:26	4	2019-07-19 16:23:26	2019-07-19 16:23:26
37ELDJB76WLX26Z23LUFT4MFVANT4I6LOAGBFTSMKBDSX7HEAM2Q====	2019-07-20 16:53:59	5	2019-07-19 16:53:59	2019-07-19 16:53:59
WBFNV3FQ7WBM2NO5PUZUKRUMZXPPCUW7FS6S3SXZE2XV3ABDPUHA====	2019-07-20 16:54:05	5	2019-07-19 16:54:05	2019-07-19 16:54:05
ZWHHVDGEVOUEF5ETGEFSJTAZ6PBWGKEI44TS26GSMEQ37BRP2J3Q====	2019-07-20 16:54:48	6	2019-07-19 16:54:48	2019-07-19 16:54:48
XQZKPSVJZCGUCSV2DFNMOPDAVAQ5NLDJX2QYXOVKUPC2PORPTDIQ====	2019-07-20 16:54:51	6	2019-07-19 16:54:51	2019-07-19 16:54:51
Y5AJSKXZPRSKUY5O6ZOCYK6U6TT2SFV3YF3CSHROU4AZRHH3RYDQ====	2019-07-20 16:58:36	4	2019-07-19 16:58:36	2019-07-19 16:58:36
N6KAU6YCTCWQGQ6BLY6DYH4IGMDUE3TFSZK2ROWYJBBSODSCGKVQ====	2019-08-02 15:44:13	7	2019-08-01 15:44:13	2019-08-01 15:44:13
EIK6CFYT4GCDSJ4LLS2IOWDOHTPPDTQM6KJT562DZGQOU2NCC23A====	2019-08-02 15:44:31	7	2019-08-01 15:44:31	2019-08-01 15:44:31
NPTOTDID3OLZXV7LFH6DGKUED4F7AMGNT5D4RTODR4J2BAO5DQHQ====	2019-08-06 18:19:23	8	2019-08-05 18:19:23	2019-08-05 18:19:23
MX7JN33SZ6CMR4DEUUYEZRAI3K6ITSSMUSPCSRLOED5OYRMUDRTQ====	2019-08-06 18:19:26	8	2019-08-05 18:19:26	2019-08-05 18:19:26
3JDHSBQXS2DLUNLLOFGVKWSJBCMPRML75WVZIV37VQIKC5NLTGJA====	2019-08-06 18:20:23	9	2019-08-05 18:20:23	2019-08-05 18:20:23
FMB46OFWE5EOLNXEFEH6TNACWW5PBNZMLNRWYPARUA4I2H3LZOSQ====	2019-08-06 18:20:28	9	2019-08-05 18:20:28	2019-08-05 18:20:28
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: webcat
--

COPY public.users (id, email, first_name, last_name, middle_name, nickname, active, inserted_at, updated_at, role) FROM stdin;
1	wcat_admin@msu.edu	Admin	Account	\N	\N	t	2019-06-24 17:18:18	2019-06-24 17:18:18	admin
2	test@test.com	John	Doe	James	Jim	t	2019-06-25 05:32:14	2019-06-25 05:32:14	admin
3	paul.w.irving@gmail.com	Paul	Irving	W.	\N	t	2019-07-11 16:29:41	2019-07-18 12:07:23	admin
5	tallpaul@msu.edu	Paul	Hamerski	Tall	\N	t	2019-07-19 16:53:59	2019-07-19 16:53:59	admin
6	pwirving@msu.edu	Paul	Irving	W	\N	t	2019-07-19 16:54:48	2019-07-19 16:54:48	admin
4	buscari3@msu.edu	John	Doe	\N	\N	t	2019-07-19 16:23:26	2019-07-19 16:58:29	admin
7	arnold123@msu.edu	Brennan	Arnold	J	\N	t	2019-08-01 15:44:13	2019-08-01 15:44:13	admin
9	dmcpadden621@gmail.com	Daryl	McPadden	P	\N	t	2019-08-05 18:20:23	2019-08-05 18:20:23	admin
8	wangvane@msu.edu	Vanessa	Wang	Yiwen	\N	t	2019-08-05 18:19:23	2019-08-05 18:21:53	admin
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.categories_id_seq', 115, true);


--
-- Name: classrooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.classrooms_id_seq', 2, true);


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.comments_id_seq', 2, true);


--
-- Name: drafts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.drafts_id_seq', 9, true);


--
-- Name: emails_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.emails_id_seq', 1, false);


--
-- Name: explanations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.explanations_id_seq', 1, false);


--
-- Name: feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.feedback_id_seq', 227, true);


--
-- Name: grades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.grades_id_seq', 4, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: observations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.observations_id_seq', 137, true);


--
-- Name: rotation_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.rotation_groups_id_seq', 2, true);


--
-- Name: rotations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.rotations_id_seq', 3, true);


--
-- Name: sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.sections_id_seq', 3, true);


--
-- Name: semesters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.semesters_id_seq', 3, true);


--
-- Name: student_explanations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.student_explanations_id_seq', 1, false);


--
-- Name: student_feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.student_feedback_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: webcat
--

SELECT pg_catalog.setval('public.users_id_seq', 9, true);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: classroom_categories classroom_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.classroom_categories
    ADD CONSTRAINT classroom_categories_pkey PRIMARY KEY (category_id, classroom_id);


--
-- Name: classroom_users classroom_users_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.classroom_users
    ADD CONSTRAINT classroom_users_pkey PRIMARY KEY (user_id, classroom_id);


--
-- Name: classrooms classrooms_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT classrooms_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: drafts drafts_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: explanations explanations_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.explanations
    ADD CONSTRAINT explanations_pkey PRIMARY KEY (id);


--
-- Name: feedback feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_pkey PRIMARY KEY (id);


--
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: observations observations_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.observations
    ADD CONSTRAINT observations_pkey PRIMARY KEY (id);


--
-- Name: password_credentials password_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.password_credentials
    ADD CONSTRAINT password_credentials_pkey PRIMARY KEY (user_id);


--
-- Name: password_resets password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_pkey PRIMARY KEY (token);


--
-- Name: review_request review_request_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.review_request
    ADD CONSTRAINT review_request_pkey PRIMARY KEY (draft_id, user_id);


--
-- Name: rotation_group_users rotation_group_users_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotation_group_users
    ADD CONSTRAINT rotation_group_users_pkey PRIMARY KEY (rotation_group_id, user_id);


--
-- Name: rotation_groups rotation_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotation_groups
    ADD CONSTRAINT rotation_groups_pkey PRIMARY KEY (id);


--
-- Name: rotation_users rotation_users_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotation_users
    ADD CONSTRAINT rotation_users_pkey PRIMARY KEY (user_id, rotation_id);


--
-- Name: rotations rotations_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotations
    ADD CONSTRAINT rotations_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: section_users section_users_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.section_users
    ADD CONSTRAINT section_users_pkey PRIMARY KEY (user_id, section_id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: semester_users semester_users_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.semester_users
    ADD CONSTRAINT semester_users_pkey PRIMARY KEY (user_id, semester_id);


--
-- Name: semesters semesters_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.semesters
    ADD CONSTRAINT semesters_pkey PRIMARY KEY (id);


--
-- Name: student_explanations student_explanations_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.student_explanations
    ADD CONSTRAINT student_explanations_pkey PRIMARY KEY (draft_id, feedback_id, explanation_id);


--
-- Name: student_feedback student_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.student_feedback
    ADD CONSTRAINT student_feedback_pkey PRIMARY KEY (draft_id, feedback_id);


--
-- Name: token_credentials token_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.token_credentials
    ADD CONSTRAINT token_credentials_pkey PRIMARY KEY (token);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: categories_name_index; Type: INDEX; Schema: public; Owner: webcat
--

CREATE UNIQUE INDEX categories_name_index ON public.categories USING btree (name);


--
-- Name: classrooms_course_code_index; Type: INDEX; Schema: public; Owner: webcat
--

CREATE UNIQUE INDEX classrooms_course_code_index ON public.classrooms USING btree (course_code);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: webcat
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: categories categories_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: classroom_categories classroom_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.classroom_categories
    ADD CONSTRAINT classroom_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: classroom_categories classroom_categories_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.classroom_categories
    ADD CONSTRAINT classroom_categories_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES public.classrooms(id) ON DELETE CASCADE;


--
-- Name: classroom_users classroom_users_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.classroom_users
    ADD CONSTRAINT classroom_users_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES public.classrooms(id) ON DELETE CASCADE;


--
-- Name: classroom_users classroom_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.classroom_users
    ADD CONSTRAINT classroom_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: comments comments_draft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_draft_id_fkey FOREIGN KEY (draft_id) REFERENCES public.drafts(id) ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: drafts drafts_parent_draft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_parent_draft_id_fkey FOREIGN KEY (parent_draft_id) REFERENCES public.drafts(id);


--
-- Name: drafts drafts_rotation_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_rotation_group_id_fkey FOREIGN KEY (rotation_group_id) REFERENCES public.rotation_groups(id);


--
-- Name: drafts drafts_student_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_student_group_fkey FOREIGN KEY (student_id, rotation_group_id) REFERENCES public.rotation_group_users(user_id, rotation_group_id) ON DELETE CASCADE;


--
-- Name: drafts drafts_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: emails emails_draft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_draft_id_fkey FOREIGN KEY (draft_id) REFERENCES public.drafts(id) ON DELETE CASCADE;


--
-- Name: explanations explanations_feedback_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.explanations
    ADD CONSTRAINT explanations_feedback_id_fkey FOREIGN KEY (feedback_id) REFERENCES public.feedback(id) ON DELETE CASCADE;


--
-- Name: feedback feedback_observation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_observation_id_fkey FOREIGN KEY (observation_id) REFERENCES public.observations(id) ON DELETE CASCADE;


--
-- Name: student_explanations fk_student_feedback; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.student_explanations
    ADD CONSTRAINT fk_student_feedback FOREIGN KEY (draft_id, feedback_id) REFERENCES public.student_feedback(draft_id, feedback_id) ON DELETE CASCADE;


--
-- Name: grades grades_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: grades grades_draft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_draft_id_fkey FOREIGN KEY (draft_id) REFERENCES public.drafts(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_draft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_draft_id_fkey FOREIGN KEY (draft_id) REFERENCES public.drafts(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: observations observations_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.observations
    ADD CONSTRAINT observations_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: password_credentials password_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.password_credentials
    ADD CONSTRAINT password_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: password_resets password_resets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: review_request review_request_draft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.review_request
    ADD CONSTRAINT review_request_draft_id_fkey FOREIGN KEY (draft_id) REFERENCES public.drafts(id) ON DELETE CASCADE;


--
-- Name: review_request review_request_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.review_request
    ADD CONSTRAINT review_request_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rotation_group_users rotation_group_users_rotation_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotation_group_users
    ADD CONSTRAINT rotation_group_users_rotation_group_id_fkey FOREIGN KEY (rotation_group_id) REFERENCES public.rotation_groups(id) ON DELETE CASCADE;


--
-- Name: rotation_group_users rotation_group_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotation_group_users
    ADD CONSTRAINT rotation_group_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rotation_groups rotation_groups_rotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotation_groups
    ADD CONSTRAINT rotation_groups_rotation_id_fkey FOREIGN KEY (rotation_id) REFERENCES public.rotations(id) ON DELETE CASCADE;


--
-- Name: rotation_users rotation_users_rotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotation_users
    ADD CONSTRAINT rotation_users_rotation_id_fkey FOREIGN KEY (rotation_id) REFERENCES public.rotations(id) ON DELETE CASCADE;


--
-- Name: rotation_users rotation_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotation_users
    ADD CONSTRAINT rotation_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rotations rotations_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.rotations
    ADD CONSTRAINT rotations_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- Name: section_users section_users_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.section_users
    ADD CONSTRAINT section_users_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- Name: section_users section_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.section_users
    ADD CONSTRAINT section_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sections sections_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES public.classrooms(id) ON DELETE CASCADE;


--
-- Name: sections sections_semester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_semester_id_fkey FOREIGN KEY (semester_id) REFERENCES public.semesters(id) ON DELETE CASCADE;


--
-- Name: semester_users semester_users_semester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.semester_users
    ADD CONSTRAINT semester_users_semester_id_fkey FOREIGN KEY (semester_id) REFERENCES public.semesters(id) ON DELETE CASCADE;


--
-- Name: semester_users semester_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.semester_users
    ADD CONSTRAINT semester_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: student_explanations student_explanations_explanation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.student_explanations
    ADD CONSTRAINT student_explanations_explanation_id_fkey FOREIGN KEY (explanation_id) REFERENCES public.explanations(id) ON DELETE CASCADE;


--
-- Name: student_feedback student_feedback_draft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.student_feedback
    ADD CONSTRAINT student_feedback_draft_id_fkey FOREIGN KEY (draft_id) REFERENCES public.drafts(id) ON DELETE CASCADE;


--
-- Name: student_feedback student_feedback_feedback_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.student_feedback
    ADD CONSTRAINT student_feedback_feedback_id_fkey FOREIGN KEY (feedback_id) REFERENCES public.feedback(id) ON DELETE CASCADE;


--
-- Name: token_credentials token_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: webcat
--

ALTER TABLE ONLY public.token_credentials
    ADD CONSTRAINT token_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

