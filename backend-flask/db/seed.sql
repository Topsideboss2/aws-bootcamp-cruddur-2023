-- this file was manually created
INSERT INTO public.users (display_name, email, handle, cognito_user_id)
VALUES
  ('Andrew Brown', 'andrew@exampro.co', 'Murithi777' , 'MOCK'),
  ('Mark Kibara', 'markkibara2014@gmail.com', 'Topsideboss2', 'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'Topsideboss2' LIMIT 1),
    'Hey everyone, welcome to my Cruddur Web App!',
    current_timestamp + interval '10 day'
  )