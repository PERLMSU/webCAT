--
-- Auto-timestamp function for triggers
--

CREATE OR REPLACE FUNCTION create_timestamps()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.created_at = now();
            NEW.updated_at = now();
            RETURN NEW;   
        END;
        $$ language 'plpgsql';

CREATE OR REPLACE FUNCTION update_timestamps()   
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = now();
            RETURN NEW;   
        END;
        $$ language 'plpgsql';



--
-- Set triggers for tables
--
CREATE TRIGGER categories_insert BEFORE INSERT ON public.categories FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER categories_update BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER classrooms_insert BEFORE INSERT ON public.classrooms FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER classrooms_update BEFORE UPDATE ON public.classrooms FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER comments_insert BEFORE INSERT ON public.comments FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER comments_update BEFORE UPDATE ON public.comments FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER drafts_insert BEFORE INSERT ON public.drafts FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER drafts_update BEFORE UPDATE ON public.drafts FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER emails_insert BEFORE INSERT ON public.emails FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER emails_update BEFORE UPDATE ON public.emails FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER explanations_insert BEFORE INSERT ON public.explanations FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER explanations_update BEFORE UPDATE ON public.explanations FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER feedback_insert BEFORE INSERT ON public.feedback FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER feedback_update BEFORE UPDATE ON public.feedback FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER grades_insert BEFORE INSERT ON public.grades FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER grades_update BEFORE UPDATE ON public.grades FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER notifications_insert BEFORE INSERT ON public.notifications FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER notifications_update BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER observations_insert BEFORE INSERT ON public.observations FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER observations_update BEFORE UPDATE ON public.observations FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER password_credentials_insert BEFORE INSERT ON public.password_credentials FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER password_credentials_update BEFORE UPDATE ON public.password_credentials FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER password_resets_insert BEFORE INSERT ON public.password_resets FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER password_resets_update BEFORE UPDATE ON public.password_resets FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER rotation_groups_insert BEFORE INSERT ON public.rotation_groups FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER rotation_groups_update BEFORE UPDATE ON public.rotation_groups FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER rotations_insert BEFORE INSERT ON public.rotations FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER rotations_update BEFORE UPDATE ON public.rotations FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER sections_insert BEFORE INSERT ON public.sections FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER sections_update BEFORE UPDATE ON public.sections FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER semesters_insert BEFORE INSERT ON public.semesters FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER semesters_update BEFORE UPDATE ON public.semesters FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER student_explanations_insert BEFORE INSERT ON public.student_explanations FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER student_explanations_update BEFORE UPDATE ON public.student_explanations FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER student_feedback_insert BEFORE INSERT ON public.student_feedback FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER student_feedback_update BEFORE UPDATE ON public.student_feedback FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER token_credentials_insert BEFORE INSERT ON public.token_credentials FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER token_credentials_update BEFORE UPDATE ON public.token_credentials FOR EACH ROW EXECUTE PROCEDURE update_timestamps();

CREATE TRIGGER users_insert BEFORE INSERT ON public.users FOR EACH ROW EXECUTE PROCEDURE create_timestamps();
CREATE TRIGGER users_update BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE PROCEDURE update_timestamps();
