PGDMP         $                z            attsys    14.0    14.0 ?    W           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            X           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            Y           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            Z           1262    16425    attsys    DATABASE     b   CREATE DATABASE attsys WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_India.1252';
    DROP DATABASE attsys;
                postgres    false            P           1247    24940    vector    TYPE     E   CREATE TYPE public.vector AS (
	x numeric,
	y numeric,
	z numeric
);
    DROP TYPE public.vector;
       public          postgres    false            �            1255    66499 .   insert_into_active_session(integer, character) 	   PROCEDURE     V  CREATE PROCEDURE public.insert_into_active_session(IN cid integer, IN rno character)
    LANGUAGE plpgsql
    AS $$
	declare
		sid int;
	begin
		select session_id into sid
		from sessions
		where session_status = 'ACTIVE' or session_status = 'WAITING';
-- 		assuming sid got a value 
		insert into attendance
		values(cid,sid,rno);
	end;
$$;
 T   DROP PROCEDURE public.insert_into_active_session(IN cid integer, IN rno character);
       public          postgres    false            �            1255    50107 $   insert_into_attendance_image_table()    FUNCTION       CREATE FUNCTION public.insert_into_attendance_image_table() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	 insert into attendance_image_table(classroom_id,session_id,regnumber)
	 values
	 (new.classroom_id,new.session_id,new.regnumber);
	 return new;
end;
$$;
 ;   DROP FUNCTION public.insert_into_attendance_image_table();
       public          postgres    false            �            1255    25361 %   remove_session_key_on_session_close()    FUNCTION     �   CREATE FUNCTION public.remove_session_key_on_session_close() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if new.session_status = 'CLOSED' then
		delete from keygen
		where session_id = new.session_id;
	end if;	
	return new;
end;	
$$;
 <   DROP FUNCTION public.remove_session_key_on_session_close();
       public          postgres    false            �            1255    58373 *   set_attendance(integer, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.set_attendance(IN sid integer, IN attendance character varying)
    LANGUAGE plpgsql
    AS $$
	declare
		student json;
		rno character(10);
		isP bool;
	begin
		for student in select * from json_array_elements(attendance::json)
		 loop
   			rno := student->>'regnumber';
			isP := student->>'is_present';
			raise notice '% -> %',rno,isP;
			update attendance
			set ispresent = isP
			where regnumber = rno and session_id = sid;
  		 end loop;
	end;	 
$$;
 W   DROP PROCEDURE public.set_attendance(IN sid integer, IN attendance character varying);
       public          postgres    false            �            1255    58375 3   set_attendance(integer, integer, character varying) 	   PROCEDURE     
  CREATE PROCEDURE public.set_attendance(IN cid integer, IN sid integer, IN attendance character varying)
    LANGUAGE plpgsql
    AS $$
	declare
		student json;
		rno character(10);
		isP bool;
	begin
		for student in select * from json_array_elements(attendance::json)
		 loop
   			rno := student->>'regnumber';
			isP := student->>'is_present';
			raise notice '% -> %',rno,isP;
			update attendance
			set ispresent = isP
			where regnumber = rno and session_id = sid and classroom_id = cid;
  		 end loop;
	end;	 
$$;
 g   DROP PROCEDURE public.set_attendance(IN cid integer, IN sid integer, IN attendance character varying);
       public          postgres    false            �            1259    50088 
   attendance    TABLE     �  CREATE TABLE public.attendance (
    classroom_id integer NOT NULL,
    session_id integer NOT NULL,
    regnumber character(10) NOT NULL,
    attendance1 time with time zone DEFAULT '00:00:00+05:30'::time with time zone,
    attendance2 time with time zone DEFAULT '00:00:00+05:30'::time with time zone,
    attendance3 time with time zone DEFAULT '00:00:00+05:30'::time with time zone,
    ispresent boolean DEFAULT false
);
    DROP TABLE public.attendance;
       public         heap    postgres    false            �            1259    50073    attendance_image_table    TABLE     t  CREATE TABLE public.attendance_image_table (
    classroom_id integer NOT NULL,
    session_id integer NOT NULL,
    regnumber character(10) NOT NULL,
    attendance1_fp character varying(100) DEFAULT ''::character varying,
    attendance2_fp character varying(100) DEFAULT ''::character varying,
    attendance3_fp character varying(100) DEFAULT ''::character varying
);
 *   DROP TABLE public.attendance_image_table;
       public         heap    postgres    false            �            1259    49943    classroom_attendees    TABLE     u   CREATE TABLE public.classroom_attendees (
    classroom_id integer NOT NULL,
    regnumber character(10) NOT NULL
);
 '   DROP TABLE public.classroom_attendees;
       public         heap    postgres    false            �            1259    58461 
   classrooms    TABLE       CREATE TABLE public.classrooms (
    classroom_id integer NOT NULL,
    teacher_id character(10) NOT NULL,
    department_id character varying(10) NOT NULL,
    course_id character varying(10) NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL
);
    DROP TABLE public.classrooms;
       public         heap    postgres    false            �            1259    58460    classrooms_classroom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.classrooms_classroom_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.classrooms_classroom_id_seq;
       public          postgres    false    221            [           0    0    classrooms_classroom_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.classrooms_classroom_id_seq OWNED BY public.classrooms.classroom_id;
          public          postgres    false    220            �            1259    24814    courses    TABLE     ~   CREATE TABLE public.courses (
    course_id character varying(10) NOT NULL,
    course_name character varying(50) NOT NULL
);
    DROP TABLE public.courses;
       public         heap    postgres    false            �            1259    24719    departments    TABLE     �   CREATE TABLE public.departments (
    department_id character varying(10) NOT NULL,
    department_name character varying(50) NOT NULL
);
    DROP TABLE public.departments;
       public         heap    postgres    false            �            1259    49958    keygen    TABLE     �   CREATE TABLE public.keygen (
    session_id integer NOT NULL,
    session_key character varying(20) NOT NULL,
    popup1 time with time zone NOT NULL,
    popup2 time with time zone NOT NULL,
    popup3 time with time zone NOT NULL
);
    DROP TABLE public.keygen;
       public         heap    postgres    false            �            1259    25160    sessions    TABLE     b  CREATE TABLE public.sessions (
    session_id integer NOT NULL,
    session_date date NOT NULL,
    start_time time with time zone NOT NULL,
    end_time time with time zone NOT NULL,
    classroom_id integer NOT NULL,
    session_status character varying(15) DEFAULT 'WAITING'::character varying NOT NULL,
    reviewed boolean DEFAULT false NOT NULL
);
    DROP TABLE public.sessions;
       public         heap    postgres    false            �            1259    25159    sessions_session_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sessions_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.sessions_session_id_seq;
       public          postgres    false    214            \           0    0    sessions_session_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.sessions_session_id_seq OWNED BY public.sessions.session_id;
          public          postgres    false    213            �            1259    58360    students    TABLE     d  CREATE TABLE public.students (
    regnumber character(10) NOT NULL,
    password character varying(70) NOT NULL,
    firstname character varying(50) NOT NULL,
    lastname character varying(50),
    email character varying(60) DEFAULT ''::character varying,
    picture character varying(100) DEFAULT ''::character varying,
    status integer NOT NULL
);
    DROP TABLE public.students;
       public         heap    postgres    false            �            1259    24821    teachers    TABLE     >  CREATE TABLE public.teachers (
    teacher_id character varying(10) NOT NULL,
    email character varying(50) DEFAULT ''::character varying NOT NULL,
    firstname character varying(50) NOT NULL,
    lastname character varying(50),
    password character varying(70) NOT NULL,
    status integer DEFAULT 1 NOT NULL
);
    DROP TABLE public.teachers;
       public         heap    postgres    false            �           2604    58464    classrooms classroom_id    DEFAULT     �   ALTER TABLE ONLY public.classrooms ALTER COLUMN classroom_id SET DEFAULT nextval('public.classrooms_classroom_id_seq'::regclass);
 F   ALTER TABLE public.classrooms ALTER COLUMN classroom_id DROP DEFAULT;
       public          postgres    false    220    221    221            �           2604    25163    sessions session_id    DEFAULT     z   ALTER TABLE ONLY public.sessions ALTER COLUMN session_id SET DEFAULT nextval('public.sessions_session_id_seq'::regclass);
 B   ALTER TABLE public.sessions ALTER COLUMN session_id DROP DEFAULT;
       public          postgres    false    213    214    214            Q          0    50088 
   attendance 
   TABLE DATA           {   COPY public.attendance (classroom_id, session_id, regnumber, attendance1, attendance2, attendance3, ispresent) FROM stdin;
    public          postgres    false    218   �[       P          0    50073    attendance_image_table 
   TABLE DATA           �   COPY public.attendance_image_table (classroom_id, session_id, regnumber, attendance1_fp, attendance2_fp, attendance3_fp) FROM stdin;
    public          postgres    false    217   S\       N          0    49943    classroom_attendees 
   TABLE DATA           F   COPY public.classroom_attendees (classroom_id, regnumber) FROM stdin;
    public          postgres    false    215   �\       T          0    58461 
   classrooms 
   TABLE DATA           l   COPY public.classrooms (classroom_id, teacher_id, department_id, course_id, from_date, to_date) FROM stdin;
    public          postgres    false    221   �\       J          0    24814    courses 
   TABLE DATA           9   COPY public.courses (course_id, course_name) FROM stdin;
    public          postgres    false    210   b]       I          0    24719    departments 
   TABLE DATA           E   COPY public.departments (department_id, department_name) FROM stdin;
    public          postgres    false    209   �]       O          0    49958    keygen 
   TABLE DATA           Q   COPY public.keygen (session_id, session_key, popup1, popup2, popup3) FROM stdin;
    public          postgres    false    216    ^       M          0    25160    sessions 
   TABLE DATA           z   COPY public.sessions (session_id, session_date, start_time, end_time, classroom_id, session_status, reviewed) FROM stdin;
    public          postgres    false    214   =^       R          0    58360    students 
   TABLE DATA           d   COPY public.students (regnumber, password, firstname, lastname, email, picture, status) FROM stdin;
    public          postgres    false    219   �^       K          0    24821    teachers 
   TABLE DATA           \   COPY public.teachers (teacher_id, email, firstname, lastname, password, status) FROM stdin;
    public          postgres    false    211   �_       ]           0    0    classrooms_classroom_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.classrooms_classroom_id_seq', 25, true);
          public          postgres    false    220            ^           0    0    sessions_session_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.sessions_session_id_seq', 112, true);
          public          postgres    false    213            �           2606    50077 2   attendance_image_table attendance_image_table_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.attendance_image_table
    ADD CONSTRAINT attendance_image_table_pkey PRIMARY KEY (classroom_id, session_id, regnumber);
 \   ALTER TABLE ONLY public.attendance_image_table DROP CONSTRAINT attendance_image_table_pkey;
       public            postgres    false    217    217    217            �           2606    50092    attendance attendance_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (classroom_id, session_id, regnumber);
 D   ALTER TABLE ONLY public.attendance DROP CONSTRAINT attendance_pkey;
       public            postgres    false    218    218    218            �           2606    49947 ,   classroom_attendees classroom_attendees_pkey 
   CONSTRAINT        ALTER TABLE ONLY public.classroom_attendees
    ADD CONSTRAINT classroom_attendees_pkey PRIMARY KEY (regnumber, classroom_id);
 V   ALTER TABLE ONLY public.classroom_attendees DROP CONSTRAINT classroom_attendees_pkey;
       public            postgres    false    215    215            �           2606    58466    classrooms classrooms_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT classrooms_pkey PRIMARY KEY (classroom_id, department_id, course_id, teacher_id, from_date, to_date);
 D   ALTER TABLE ONLY public.classrooms DROP CONSTRAINT classrooms_pkey;
       public            postgres    false    221    221    221    221    221    221            �           2606    24818    courses courses_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);
 >   ALTER TABLE ONLY public.courses DROP CONSTRAINT courses_pkey;
       public            postgres    false    210            �           2606    24723    departments departments_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);
 F   ALTER TABLE ONLY public.departments DROP CONSTRAINT departments_pkey;
       public            postgres    false    209            �           2606    49962    keygen keygen_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.keygen
    ADD CONSTRAINT keygen_pkey PRIMARY KEY (session_key);
 <   ALTER TABLE ONLY public.keygen DROP CONSTRAINT keygen_pkey;
       public            postgres    false    216            �           2606    58315    sessions sessions_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (session_id, start_time, end_time, session_date);
 @   ALTER TABLE ONLY public.sessions DROP CONSTRAINT sessions_pkey;
       public            postgres    false    214    214    214    214            �           2606    25167     sessions sessions_session_id_key 
   CONSTRAINT     a   ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_session_id_key UNIQUE (session_id);
 J   ALTER TABLE ONLY public.sessions DROP CONSTRAINT sessions_session_id_key;
       public            postgres    false    214            �           2606    58364    students students_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (regnumber);
 @   ALTER TABLE ONLY public.students DROP CONSTRAINT students_pkey;
       public            postgres    false    219            �           2606    24825    teachers teachers_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (teacher_id);
 @   ALTER TABLE ONLY public.teachers DROP CONSTRAINT teachers_pkey;
       public            postgres    false    211            �           2606    82884    classrooms unique_clasroom_id 
   CONSTRAINT     `   ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT unique_clasroom_id UNIQUE (classroom_id);
 G   ALTER TABLE ONLY public.classrooms DROP CONSTRAINT unique_clasroom_id;
       public            postgres    false    221            �           2620    25363 4   sessions remove_session_key_on_session_close_trigger    TRIGGER     �   CREATE TRIGGER remove_session_key_on_session_close_trigger AFTER UPDATE ON public.sessions FOR EACH ROW EXECUTE FUNCTION public.remove_session_key_on_session_close();
 M   DROP TRIGGER remove_session_key_on_session_close_trigger ON public.sessions;
       public          postgres    false    214    223            �           2620    50108 .   attendance trigger_into_attendance_image_table    TRIGGER     �   CREATE TRIGGER trigger_into_attendance_image_table AFTER INSERT ON public.attendance FOR EACH ROW EXECUTE FUNCTION public.insert_into_attendance_image_table();
 G   DROP TRIGGER trigger_into_attendance_image_table ON public.attendance;
       public          postgres    false    218    224            �           2606    58395 I   attendance_image_table attendance_image_table_regnumber_classroom_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.attendance_image_table
    ADD CONSTRAINT attendance_image_table_regnumber_classroom_id_fkey FOREIGN KEY (classroom_id, regnumber) REFERENCES public.classroom_attendees(classroom_id, regnumber) ON DELETE CASCADE NOT VALID;
 s   ALTER TABLE ONLY public.attendance_image_table DROP CONSTRAINT attendance_image_table_regnumber_classroom_id_fkey;
       public          postgres    false    215    217    217    3236    215            �           2606    58390 =   attendance_image_table attendance_image_table_session_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.attendance_image_table
    ADD CONSTRAINT attendance_image_table_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(session_id) ON DELETE CASCADE NOT VALID;
 g   ALTER TABLE ONLY public.attendance_image_table DROP CONSTRAINT attendance_image_table_session_id_fkey;
       public          postgres    false    214    217    3234            �           2606    58410 1   attendance attendance_regnumber_classroom_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_regnumber_classroom_id_fkey FOREIGN KEY (classroom_id, regnumber) REFERENCES public.classroom_attendees(classroom_id, regnumber) ON DELETE CASCADE NOT VALID;
 [   ALTER TABLE ONLY public.attendance DROP CONSTRAINT attendance_regnumber_classroom_id_fkey;
       public          postgres    false    218    215    215    3236    218            �           2606    58400 %   attendance attendance_session_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(session_id) ON DELETE CASCADE NOT VALID;
 O   ALTER TABLE ONLY public.attendance DROP CONSTRAINT attendance_session_id_fkey;
       public          postgres    false    218    214    3234            �           2606    82895 4   classroom_attendees classroom_attendees_classroom_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.classroom_attendees
    ADD CONSTRAINT classroom_attendees_classroom_id FOREIGN KEY (classroom_id) REFERENCES public.classrooms(classroom_id) ON DELETE CASCADE NOT VALID;
 ^   ALTER TABLE ONLY public.classroom_attendees DROP CONSTRAINT classroom_attendees_classroom_id;
       public          postgres    false    215    3248    221            �           2606    58385 6   classroom_attendees classroom_attendees_regnumber_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.classroom_attendees
    ADD CONSTRAINT classroom_attendees_regnumber_fkey FOREIGN KEY (regnumber) REFERENCES public.students(regnumber) ON DELETE CASCADE NOT VALID;
 `   ALTER TABLE ONLY public.classroom_attendees DROP CONSTRAINT classroom_attendees_regnumber_fkey;
       public          postgres    false    3244    219    215            �           2606    58477     classrooms fk_courses_classrooms    FK CONSTRAINT     �   ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT fk_courses_classrooms FOREIGN KEY (course_id) REFERENCES public.courses(course_id) ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.classrooms DROP CONSTRAINT fk_courses_classrooms;
       public          postgres    false    210    221    3228            �           2606    58472 $   classrooms fk_departments_classrooms    FK CONSTRAINT     �   ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT fk_departments_classrooms FOREIGN KEY (department_id) REFERENCES public.departments(department_id) ON DELETE CASCADE;
 N   ALTER TABLE ONLY public.classrooms DROP CONSTRAINT fk_departments_classrooms;
       public          postgres    false    209    221    3226            �           2606    58467 !   classrooms fk_teachers_classrooms    FK CONSTRAINT     �   ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT fk_teachers_classrooms FOREIGN KEY (teacher_id) REFERENCES public.teachers(teacher_id) ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.classrooms DROP CONSTRAINT fk_teachers_classrooms;
       public          postgres    false    211    221    3230            �           2606    49963    keygen keygen_session_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.keygen
    ADD CONSTRAINT keygen_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(session_id);
 G   ALTER TABLE ONLY public.keygen DROP CONSTRAINT keygen_session_id_fkey;
       public          postgres    false    214    3234    216            �           2606    82900    sessions session_classroom_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT session_classroom_fkey FOREIGN KEY (classroom_id) REFERENCES public.classrooms(classroom_id) ON DELETE CASCADE NOT VALID;
 I   ALTER TABLE ONLY public.sessions DROP CONSTRAINT session_classroom_fkey;
       public          postgres    false    221    3248    214            Q   I   x�}��	�@��n+�$�[����
�9B>ITA*�,���m�Pn�7��7���`�+��{nsf��4�      P   W   x���;
�@ �:9��#�&�Al���?j%�i;��
"
��"�y �W(��u�-��3�=������w�f���#֏F��68D<M�7y      N       x�32�420204450��2B�r��qqq a�|      T   h   x���1
�0E��.��ǤuA7G�kQ�������)w���q�@d�8PP� ��R����s�?e�b;jE'�]��~��=�u1�}�q��G>��!�H+C      J   _   x�%��	�0 ��)2��� !�6Ї����sh���Ķyu����v���!����b1CG��.�U(��PT^��q�g��H�Q,|C�' x ˁ�      I   ?   x�����s��u���Squ�����w���29A��������������k���;W� ���      O      x������ � �      M   8   x�344�4202�50�56�40�24�20�60��p���F���>���.�%\1z\\\ f��      R     x���MS�0 D�����&)��*)�Zt�$$MMZ�e˯�qowo�D��<0"l��Q@�c�8�|�m��h�N����P����3�O�J.	�}v��� �VM: q���*Ͳ� �kg����4�M��v����4
�Z���6��P��3��n�֝�qg�8N��X.��a۹"N�����X�C[7�J<�\V  �K���:��ɩ/�!4{��ЙVo�f6:,�3�{ʋ"p�4�}	Y30PV�����}���-���y      K   I  x�M��r�@��u����]���`@D*�K�h�Ad�>I�&.Ͽ8��%+��UdA~�)�ה��3`)O��_E?�0�}~�{]#�Μ�S�b�So�xM�9��!]���~c:QT$lEw�aNĒ���>���=%D͋�r������O������ 7��ż�s����U.�^�z�H�L�n{�.9����j������TAV��ȅ�O(����7?Lb>փ%�<�탵��r��Li���qq_k�R�k�����EQeYD�瘕U�CF;��|H�#eI�'w���1Hc� _k�kY� ���ϭ�&e(ξ2fH�>y��!��     