# Week 3 — Decentralized Authentication

## Topics
* [Setup an Amazon Cognito user-pool through the Amazon Console](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week3.md#setup-user-pool)
* [Install AWS Amplify library](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week3.md#install-aws-amplify-library)
* [Create and verify a user through the Console and CLI respectively](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week3.md#create-a-user-through-the-console)
* [Configure authentication on my Sign-in Page](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week3.md#sign-in-page)
* [Configure authentication on my Sign-up Page](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week3.md#sign-up-page)
* [Configure authentication on my Confirmation Page](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week3.md#confirmation-page)
* [Configure authentication on my Password recovery Page](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week3.md#password-recovery-page)
* [Implement the use of a JWT to pass API calls to the backend](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week3.md#implement-the-use-of-a-json-web-token)

## Setup User-pool
Using the Amazon Console, I was able to create a user-pool with the following steps.
1. Use the search bar to find Amazon Cognito

2. Select create new user pool

3. Configure Sign in experience as shown below
![](../_docs/assets/User-pool-Step1.png)

4. Configure security requirements as shown below
![](../_docs/assets/User-pool-Step2.1.png)
![](../_docs/assets/User-pool-Step2.2.png)

5. Configure Sign up experience as shown below
![](../_docs/assets/User-pool-Step3.1.png)
![](../_docs/assets/User-pool-Step3.2.png)
![](../_docs/assets/User-pool-Step3.3.png)

6. Configure message delivery as shown below
![](../_docs/assets/User-pool-Step4.png)

7. Configure app integration as shown below
![](../_docs/assets/User-pool-Step5.1.png)
![](../_docs/assets/User-pool-Step5.2.png)

Finally, confirm the user-pool details and home page should be as shown below
![](../_docs/assets/User-pool-Page.png)

## Install AWS Amplify library
### What is AWS Amplify?
You can think of AWS Amplify as client library that lets you build and deploy serverless applications in the cloud. It is a full-stack application platform that is a combination of both client-side and server-side code. It  includes features such as user authentication, authorization, and analytics that help developers build secure and scalable applications quickly and easily.
I used AWS Amplify to integrate authorization using Amazon Cognito into my code
1. Install AWS Amplify library.

In the `/frontend-react-js/` directory run:
```shell
npm install aws-amplify --save
```
2. Add env vars

In the `docker-compose.yml` file:
```yaml
  frontend-react-js:
    environment:
      REACT_APP_AWS_PROJECT_REGION: "${AWS_DEFAULT_REGION}"
      REACT_APP_AWS_COGNITO_REGION: "${AWS_DEFAULT_REGION}"
      REACT_APP_AWS_USER_POOLS_ID: "us-east-1_*******"
      REACT_APP_CLIENT_ID: "*********************"
```

3. Edit app.js
```javascript
import { Amplify } from 'aws-amplify';

Amplify.configure({
    "AWS_PROJECT_REGION": process.env.REACT_AWS_PROJECT_REGION,
    "aws_cognito_identity_pool_id": process.env.REACT_APP_AWS_COGNITO_IDENTITY_POOL_ID,
    "aws_cognito_region": process.env.REACT_APP_AWS_COGNITO_REGION,
    "aws_user_pools_id": process.env.REACT_APP_AWS_USER_POOLS_ID,
    "aws_user_pools_web_client_id": process.env.REACT_APP_CLIENT_ID,
    "oauth": {},
    Auth: {
        // We are not using an Identity Pool
        // identityPoolId: process.env.REACT_APP_IDENTITY_POOL_ID, // REQUIRED - Amazon Cognito Identity Pool ID
        region: process.env.REACT_AWS_PROJECT_REGION,           // REQUIRED - Amazon Cognito Region
        userPoolId: process.env.REACT_APP_AWS_USER_POOLS_ID,         // OPTIONAL - Amazon Cognito User Pool ID
        userPoolWebClientId: process.env.REACT_APP_AWS_USER_POOLS_WEB_CLIENT_ID,   // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
    }
});
```

3. Edit homefeedpage.js

```javascript
import { Auth } from 'aws-amplify';

// set a state
const [user, setUser] = React.useState(null);

// check if we are authenicated
const checkAuth = async () => {
  Auth.currentAuthenticatedUser({
    // Optional, By default is false. 
    // If set to true, this call will send a 
    // request to Cognito to get the latest user data
    bypassCache: false 
  })
  .then((user) => {
    console.log('user',user);
    return Auth.currentAuthenticatedUser()
  }).then((cognito_user) => {
      setUser({
        display_name: cognito_user.attributes.name,
        handle: cognito_user.attributes.preferred_username
      })
  })
  .catch((err) => console.log(err));
};

// check when the page loads if we are authenicated
React.useEffect(()=>{
  loadData();
  checkAuth();
}, [])
```

4. Edit `DesktopNavigation.js`

```javascript
import './DesktopNavigation.css';
import {ReactComponent as Logo} from './svg/logo.svg';
import DesktopNavigationLink from '../components/DesktopNavigationLink';
import CrudButton from '../components/CrudButton';
import ProfileInfo from '../components/ProfileInfo';

export default function DesktopNavigation(props) {

  let button;
  let profile;
  let notificationsLink;
  let messagesLink;
  let profileLink;
  if (props.user) {
    button = <CrudButton setPopped={props.setPopped} />;
    profile = <ProfileInfo user={props.user} />;
    notificationsLink = <DesktopNavigationLink 
      url="/notifications" 
      name="Notifications" 
      handle="notifications" 
      active={props.active} />;
    messagesLink = <DesktopNavigationLink 
      url="/messages"
      name="Messages"
      handle="messages" 
      active={props.active} />
    profileLink = <DesktopNavigationLink 
      url="/@andrewbrown" 
      name="Profile"
      handle="profile"
      active={props.active} />
  }

  return (
    <nav>
      <Logo className='logo' />
      <DesktopNavigationLink url="/" 
        name="Home"
        handle="home"
        active={props.active} />
      {notificationsLink}
      {messagesLink}
      {profileLink}
      <DesktopNavigationLink url="/#" 
        name="More" 
        handle="more"
        active={props.active} />
      {button}
      {profile}
    </nav>
  );
}
```

5. Edit `ProfileInfo.js`

```javascript
import { Auth } from 'aws-amplify';

const signOut = async () => {
  try {
      await Auth.signOut({ global: true });
      window.location.href = "/"
  } catch (error) {
      console.log('error signing out: ', error);
  }
}
```

6. Edit `DesktopSidebar.js`

```javascript
import './DesktopSidebar.css';
import Search from '../components/Search';
import TrendingSection from '../components/TrendingsSection'
import SuggestedUsersSection from '../components/SuggestedUsersSection'
import JoinSection from '../components/JoinSection'

export default function DesktopSidebar(props) {
  const trendings = [
    {"hashtag": "100DaysOfCloud", "count": 2053 },
    {"hashtag": "CloudProject", "count": 8253 },
    {"hashtag": "AWS", "count": 9053 },
    {"hashtag": "FreeWillyReboot", "count": 7753 }
  ]

  const users = [
    {"display_name": "Andrew Brown", "handle": "andrewbrown"}
  ]

  let trending;
  let suggested;
  let join;
  if (props.user) {
    trending = <TrendingSection trendings={trendings} />
    suggested = <SuggestedUsersSection users={users} />
    } else {
      join = <JoinSection />
    }
  
  return (
    <section>
      <Search />
      {trending}
      {suggested}
      {join}
      <footer>
        <a href="#">About</a>
        <a href="#">Terms of Service</a>
        <a href="#">Privacy Policy</a>
      </footer>
    </section>
  );
}
```
## Create a user through the Console
![](../_docs/assets/CreateUser.png)
![](../_docs/assets/Created-users.png)

## Verify said user through the CLI
```shell
aws cognito-idp admin-set-user-password --user-pool-id "us-east-1_******" --username ******* --password ****** --permanent
```

## Sign-in Page
In `SigninPage.js`:

```javascript
import {Auth} from 'aws-amplify';

const [errors, setErrors] = React.useState('');

const onsubmit = async (event) => {
    setErrors('')
    event.preventDefault();
    try {
        Auth.signIn(username, password)
            .then(user => {
                localStorage.setItem("access_token", user.signInUserSession.accessToken.jwtToken)
                window.location.href = "/"
            })
            .catch(err => {
                console.log('Error!', err)
            });
    } catch (error) {
        if (error.code == 'UserNotConfirmedException') {
            window.location.href = "/confirm"
        }
        setErrors(error.message)
    }
    return false
}

let errors;
if (errors) {
    errors = <div className='errors'>{errors}</div>;
}

// just before submit component
{
    errors
}
```
The SigninPage.js in question:
![](../_docs/assets/CruddurSigninPage.png)
## Sign-up Page
In `SignupPage.js`:
```javascript
import { Auth } from 'aws-amplify';

const [errors, setErrors] = React.useState('');

const onsubmit = async (event) => {
  event.preventDefault();
  setErrors('')
  try {
      const { user } = await Auth.signUp({
        username: email,
        password: password,
        attributes: {
            name: name,
            email: email,
            preferred_username: username,
        },
        autoSignIn: { // optional - enables auto sign in after user is confirmed
            enabled: true,
        }
      });
      console.log(user);
      window.location.href = `/confirm?email=${email}`
  } catch (error) {
      console.log(error);
      setErrors(error.message)
  }
  return false
}

let errors;
if (errors){
  errors = <div className='errors'>{errors}</div>;
}

//before submit component
{errors}
```

## Confirmation Page
```javascript
const resend_code = async (event) => {
  setErrors('')
  try {
    await Auth.resendSignUp(email);
    console.log('code resent successfully');
    setCodeSent(true)
  } catch (err) {
    // does not return a code
    // does cognito always return english
    // for this to be an okay match?
    console.log(err)
    if (err.message == 'Username cannot be empty'){
      setErrors("You need to provide an email in order to send Resend Activiation Code")   
    } else if (err.message == "Username/client id combination not found."){
      setErrors("Email is invalid or cannot be found.")   
    }
  }
}

const onsubmit = async (event) => {
  event.preventDefault();
  setErrors('')
  try {
    await Auth.confirmSignUp(email, code);
    window.location.href = "/"
  } catch (error) {
    setErrors(error.message)
  }
  return false
}
```
The Confirmation Page in question:
![](../_docs/assets/CruddurConfirmationPage.png)

## Password recovery Page
```javascript
import { Auth } from 'aws-amplify';

const onsubmit_send_code = async (event) => {
  event.preventDefault();
  setErrors('')
  Auth.forgotPassword(username)
  .then((data) => setFormState('confirm_code') )
  .catch((err) => setErrors(err.message) );
  return false
}

const onsubmit_confirm_code = async (event) => {
  event.preventDefault();
  setErrors('')
  if (password == passwordAgain){
    Auth.forgotPasswordSubmit(username, code, password)
    .then((data) => setFormState('success'))
    .catch((err) => setErrors(err.message) );
  } else {
    setErrors('Passwords do not match')
  }
  return false
}

```

The Password recovery page in question:
![](../_docs/assets/CruddurRecoveryPage.png)

## Implement the use of a JSON Web Token
### What is a JWT?

This image from Twitter helped me understand further what a JSON Web Token is and how it works.

![](../_docs/assets/JSONWebToken.jpg)

### Authenticating Server Side

Add in the `HomeFeedPage.js` a header to pass along the access token

```javascript
  headers: {
    Authorization: `Bearer ${localStorage.getItem("access_token")}`
}
```

Add env vars to `docker-compose.yml`:
```yaml
backend-flask:
    environment:
      AWS_COGNITO_USER_POOL_ID: "********"
      AWS_COGNITO_USER_POOL_CLIENT_ID: "**************"
```

Add a new file `backend-flask/lib/cognito_jwt_token.py`:
```python
import time
import requests
from jose import jwk, jwt
from jose.exceptions import JOSEError
from jose.utils import base64url_decode

class FlaskAWSCognitoError(Exception):
  pass

class TokenVerifyError(Exception):
  pass

def extract_access_token(request_headers):
    access_token = None
    auth_header = request_headers.get("Authorization")
    if auth_header and " " in auth_header:
        _, access_token = auth_header.split()
    return access_token

class CognitoJwtToken:
    def __init__(self, user_pool_id, user_pool_client_id, region, request_client=None):
        self.region = region
        if not self.region:
            raise FlaskAWSCognitoError("No AWS region provided")
        self.user_pool_id = user_pool_id
        self.user_pool_client_id = user_pool_client_id
        self.claims = None
        if not request_client:
            self.request_client = requests.get
        else:
            self.request_client = request_client
        self._load_jwk_keys()


    def _load_jwk_keys(self):
        keys_url = f"https://cognito-idp.{self.region}.amazonaws.com/{self.user_pool_id}/.well-known/jwks.json"
        try:
            response = self.request_client(keys_url)
            self.jwk_keys = response.json()["keys"]
        except requests.exceptions.RequestException as e:
            raise FlaskAWSCognitoError(str(e)) from e

    @staticmethod
    def _extract_headers(token):
        try:
            headers = jwt.get_unverified_headers(token)
            return headers
        except JOSEError as e:
            raise TokenVerifyError(str(e)) from e

    def _find_pkey(self, headers):
        kid = headers["kid"]
        # search for the kid in the downloaded public keys
        key_index = -1
        for i in range(len(self.jwk_keys)):
            if kid == self.jwk_keys[i]["kid"]:
                key_index = i
                break
        if key_index == -1:
            raise TokenVerifyError("Public key not found in jwks.json")
        return self.jwk_keys[key_index]

    @staticmethod
    def _verify_signature(token, pkey_data):
        try:
            # construct the public key
            public_key = jwk.construct(pkey_data)
        except JOSEError as e:
            raise TokenVerifyError(str(e)) from e
        # get the last two sections of the token,
        # message and signature (encoded in base64)
        message, encoded_signature = str(token).rsplit(".", 1)
        # decode the signature
        decoded_signature = base64url_decode(encoded_signature.encode("utf-8"))
        # verify the signature
        if not public_key.verify(message.encode("utf8"), decoded_signature):
            raise TokenVerifyError("Signature verification failed")

    @staticmethod
    def _extract_claims(token):
        try:
            claims = jwt.get_unverified_claims(token)
            return claims
        except JOSEError as e:
            raise TokenVerifyError(str(e)) from e

    @staticmethod
    def _check_expiration(claims, current_time):
        if not current_time:
            current_time = time.time()
        if current_time > claims["exp"]:
            raise TokenVerifyError("Token is expired")  # probably another exception

    def _check_audience(self, claims):
        # and the Audience  (use claims['client_id'] if verifying an access token)
        audience = claims["aud"] if "aud" in claims else claims["client_id"]
        if audience != self.user_pool_client_id:
            raise TokenVerifyError("Token was not issued for this audience")

    def verify(self, token, current_time=None):
        """ https://github.com/awslabs/aws-support-tools/blob/master/Cognito/decode-verify-jwt/decode-verify-jwt.py """
        if not token:
            raise TokenVerifyError("No token provided")

        headers = self._extract_headers(token)
        pkey_data = self._find_pkey(headers)
        self._verify_signature(token, pkey_data)

        claims = self._extract_claims(token)
        self._check_expiration(claims, current_time)
        self._check_audience(claims)

        self.claims = claims 
        return claims
```

Modify `app.py`:

```python
import sys
...

from lib.cognito_jwt_token import CognitoJwtToken, extract_access_token, TokenVerifyError

...

cognito_jwt_token = CognitoJwtToken(
    user_pool_id=os.getenv("AWS_COGNITO_USER_POOL_ID"),
    user_pool_client_id=os.getenv("AWS_COGNITO_USER_POOL_CLIENT_ID"),
    region=os.getenv("AWS_DEFAULT_REGION")
)

...

cors = CORS(
  app, 
  resources={r"/api/*": {"origins": origins}},
  headers=['Content-Type', 'Authorization'], 
  expose_headers='Authorization',
  methods="OPTIONS,GET,HEAD,POST"
)

...

@app.route("/api/activities/home", methods=['GET'])
@xray_recorder.capture('activities_home')
def data_home():
    access_token = extract_access_token(request.headers)
    try:
        claims = cognito_jwt_token.verify(access_token)
        # authenicatied request
        app.logger.debug("authenicated")
        app.logger.debug(claims)
        app.logger.debug(claims['username'])
        data = HomeActivities.run(cognito_user_id=claims['username'])
    except TokenVerifyError as e:
        # unauthenicatied request
        app.logger.debug(e)
        app.logger.debug("unauthenicated")
        data = HomeActivities.run()
    return data, 200

...
```

To `backend-flask/services/home_activities.py`:
```python
class HomeActivities:
  def run(cognito_user_id=None):

...

if cognito_user_id != None:
    extra_crud = {
        'uuid': '248959df-3079-4947-b847-9e0892d1bab4',
        'handle':  'Lore',
        'message': 'My dear brother, it the humans that are the problem',
        'created_at': (now - timedelta(hours=1)).isoformat(),
        'expires_at': (now + timedelta(hours=12)).isoformat(),
        'likes': 1042,
        'replies': []
    }
results.insert(0,extra_crud)
```

This is to verify if a user is not authenticated and logged in they should not be able to see the crud by Lore.  