import requests
import uuid


class PayPayError(Exception):
    pass


class PayPay(object):
    def __init__(self, access_token=None, device_uuid=None, client_uuid=None):
        self.host = "app4.paypay.ne.jp"
        if device_uuid:
            self.device_uuid = device_uuid
        else:
            self.device_uuid = str(uuid.uuid4()).upper()
        if client_uuid:
            self.client_uuid = device_uuid
        else:
            self.client_uuid = str(uuid.uuid4()).upper()
        self.headers = {
            'Host': self.host,
            'Client-Version': "3.58.0",
            'Device-Uuid': self.device_uuid,
            'System-Locale': 'ja',
            'User-Agent': 'PaypayApp/3.43.202205231147 CFNetwork/1126 Darwin/19.5.0',
            'Network-Status': 'WIFI',
            'Device-Name': 'iPhone9,1',
            'Client-Os-Type': 'IOS',
            'Client-Mode': 'NORMAL',
            'Client-Type': 'PAYPAYAPP',
            'Accept-Language': 'ja-jp',
            'Timezone': 'Asia/Tokyo',
            'Accept': '*/*',
            'Client-Uuid': self.client_uuid,
            'Client-Os-Version': '13.5.0',
        }
        if access_token:
            self.headers["Authorization"] = "Bearer " + access_token
        self.params = {
            'payPayLang': 'ja'
        }

    def login(self, phoneNumber, password):
        json_data = {
            'phoneNumber': phoneNumber,
            'password': password,
            'signInAttemptCount': 1,
        }

        response = requests.post(f'https://{self.host}/bff/v1/signIn', params=self.params, headers=self.headers,
                                 json=json_data).json()
        if response['header']['resultCode'] == "S0000":
            self.headers["Authorization"] = "Bearer " + response["payload"]["accessToken"]
            return response
        elif response['header']['resultCode'] == "S1004":
            return response
        else:
            raise PayPayError(response['header']['resultCode'], response['header']['resultMessage'])

    def login_otp(self, otpReferenceId, otp):
        json_data = {
            'otpReferenceId': otpReferenceId,
            'otp': otp,
        }

        response = requests.post(f'https://{self.host}/bff/v1/signInWithSms', params=self.params, headers=self.headers,
                                 json=json_data).json()
        if response['header']['resultCode'] == "S0000":
            self.headers["Authorization"] = "Bearer " + response["payload"]["accessToken"]
            return response
        else:
            raise PayPayError(response['header']['resultCode'], response['header']['resultMessage'])


login_data = PayPay.login(self=PayPay(), phoneNumber="電話番号",
                               password="パスわーd")
print(login_data)
print(login_data["error"]["otpReferenceId"])
print(PayPay.login_otp(self=PayPay(), otpReferenceId=str(login_data["error"]["otpReferenceId"]),
                            otp=str(input("otpコード"))))
