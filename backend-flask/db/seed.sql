-- this file was manually created
INSERT INTO public.users (display_name, email, handle, cognito_user_id)
VALUES
  ('Mark Kibara', 'markkibara2014@gmail.com', 'Topsideboss2', 'fb3dbe3e-43ae-42a2-b139-2cc33b64f655'),
  ('Mark Kibara', 'markmurithi777@gmail.com', 'Murithi777' , '98a3bcbb-c348-4bc4-96dc-a33773aadb4c'),
  ('Aubrey Drake', 'aubreydrake@gmail.com', 'drizzy', 'MOCK');
INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'Topsideboss2' LIMIT 1),
    'Hey everyone, welcome to my Cruddur Web App!',
    current_timestamp + interval '10 day'
  )