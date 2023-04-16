-- this file was manually created
INSERT INTO public.users (display_name, email, handle, cognito_user_id)
VALUES
  ('Mark Kibara', 'markkibara2014@gmail.com', 'Topsideboss2', 'fb3dbe3e-43ae-42a2-b139-2cc33b64f655'),
  ('Mark Kibara', 'markmurithi777@gmail.com', 'Murithi777' , '98a3bcbb-c348-4bc4-96dc-a33773aadb4c'),
  ('Aubrey Drake', 'aubreydrake@gmail.com', 'drizzy', 'MOCK');
DELETE FROM users WHERE uuid = '3cc8f397-b813-4889-90ba-781646bb72c9', '26626de4-9886-440e-a070-b382c44f6be1', '083e55a2-0df3-42cc-9ca8-f685109905cc', '6ed71aa3-c633-43bd-add1-286f3c99fae2', '34c1a0f2-c8c2-49e9-b81c-f6937c9da195';
INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'Topsideboss2' LIMIT 1),
    'Hey everyone, welcome to my Cruddur Web App!',
    current_timestamp + interval '10 day'
  )