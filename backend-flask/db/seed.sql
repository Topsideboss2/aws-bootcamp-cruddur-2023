-- this file was manually created
INSERT INTO public.users (display_name, handle, email, cognito_user_id)
VALUES
  ('Andrew Brown', 'andrewbrown' , 'andrew@exampro.co' , 'MOCK'),
  ('Mark Kibara', 'topsideboss2', 'markkibara2014@gmail.com', 'MOCK'),
  ('Andrew Bayko', 'bayko' , 'andrewbayko@exampro.co' , 'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'topsideboss2' LIMIT 1),
    'Hey everyone, welcome to my Cruddur Web App!',
    current_timestamp + interval '10 day'
  )