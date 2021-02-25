import json

from time import sleep
from pathlib import Path

import requests

from requests_toolbelt.adapters import source
from lxml import etree


class RequestError(Exception):
    pass


class EmptyResultError(Exception):
    pass


class NotImplementedException(Exception):
    pass


class BatchNotEmpty(Exception):
    pass


class IDChecker():
    
    URI = (
        "https://is.muni.cz/dok/depository_in"
        "?"
            "vybos_vzorek_last="
            "&vybos_vzorek={id}"
            "&vybos_hledej=Vyhledat+osobu"
    )
    MAIN_XPATH = (
        "//div[contains(@class,'vizitka')]"
    )
    UCO_XPATH = (
        "//a[contains(@class,'okno') and text() = 'Osobní stránka']/@href"
    )
    NAME_XPATH = (
        "//h3/text()"
    )

    def __init__(self, src_ip):
        self.src_ip = src_ip
    
    def rotate_ip(self, src_ip):
        self.src_ip = src_ip
    
    def request(self, user_id):
        responses = []
        with requests.Session() as s:
            src_adapter = source.SourceAddressAdapter(self.src_ip)
            s.mount('http://', src_adapter)
            s.mount('https://', src_adapter)
            r = s.get(IDChecker.URI.format(id=user_id))
            if not r.ok:
                raise RequestError(f"Status code - {r.status_code}")
        t = etree.fromstring(r.text, parser=etree.HTMLParser())
        r = t.xpath(IDChecker.MAIN_XPATH)

        if len(r) == 0:
            raise EmptyResultError()

        results = []
        for e in r:
            uco = e.xpath(IDChecker.UCO_XPATH)[0]
            uco = uco.split('/')[2]
            name = ""
            for i in e.xpath(IDChecker.NAME_XPATH):
                if uco in i:
                    name = i
            results.append(
                (uco, name)
            )
        return results


class IDGenerator():

    def fetch_id(self):
        raise NotImplementedException()

    def mark_success(self, user_id, uco, name):
        raise NotImplementedException()

    def mark_failure(self, user_id):
        raise NotImplementedException()


class RESTIDSGenerator(IDGenerator):
    """
    Fetch URL:
    json params {"node": uid}
    uid identifies a single node
    success response - any beow 400
    response contents - line delimited list of ids
    
    Upload URL:
    json params: 
    {
        "node": uid,
        "success": [
            {
                "user_id": user_id,
                "uco": uco, 
                "name": name
            }
        ],
        "fail": [
            user_id
        ]
    }
    success response - any below 400
    """

    def __init__(
        self, 
        uid, 
        fetch_url, 
        upload_url,
        sync_limit
    ):
        self.uid = uid
        self.fresh_batch = []
        
        self.success_batch = []
        self.failure_batch = []

        self.FETCH_URL = fetch_url
        self.UPLOAD_URL = upload_url

        self.sync_limit = sync_limit


    def fetch_id(self):
        if len(self.fresh_batch) == 0:
            self.__fetch_batch()
        if len(self.fresh_batch) == 0:
            return None
        return self.fresh_batch.pop()

    def mark_success(self, user_id, uco, name):
        self.success_batch.append(
            (user_id, uco, name)
        )
        self.__conditional_upload()

    def mark_failure(self, user_id):
        self.failure_batch.append(user_id)
        self.__conditional_upload()

    def __conditional_upload(self):
        if len(self.success_batch) + len(self.failure_batch) >= self.sync_limit:
            self.__upload_results()

    def __fetch_batch(self):
        if len(self.fresh_batch) != 0:
            raise BatchNotEmpty()

        r = requests.post(
            RESTIDSGenerator.FETCH_URL, 
            json={"node": self.uid}
        )
        if not r.ok:
            raise RequestError(f"Status code - {r.status_code}")
        l = r.text.split()
        l.reverse()
        self.fresh_batch = l
    
    def __upload_results(self):
        upload_json = {
            "node" : self.uid,
            "success" : [
                {
                    "user_id" : user_id, 
                    "uco" : uco, 
                    "name" : name
                } for user_id, uco, name in self.success_batch
            ],
            "fail" : self.failure_batch
        }
        r = requests.post(
            RESTIDSGenerator.UPLOAD_URL,
            json=upload_json
        )
        if not r.ok:
            raise RequestError(f"Status code - {r.status_code}")
        self.success_batch.clear()
        self.failure_batch.clear()


class LocalGenerator(IDGenerator):
    
    def __init__(self, in_path, success_path, fail_path):
        self.in_file = in_pah.open('r')
        self.s_file = success_path.open('w')
        self.f_file = fail_path.open('w')
    

    def fetch_id(self):
        if len(self.batch) == 0:
            return None
        return self.batch.pop()

    def mark_success(self, user_id, uco, name):
        s = (
            f'"{user_id}",'
            f'"{uco}"",'
            f'"{name}"\n'
        )
        self.s_file.write(s)

    def mark_failure(self, user_id):
        s = f'"{user_id}"'
        self.f_file.write(s)
    
    def cleanup(self):
        self.in_file.close()
        self.s_file.close()
        self.f_file.close()


class TestGenerator(IDGenerator):
    
    def __init__(self):
        self.batch = [
        ]
    
    def fetch_id(self):
        if len(self.batch) == 0:
            return None
        return self.batch.pop()

    def mark_success(self, user_id, uco, name):
        print(
            "Success:\n"
            f"\tuser_id: {user_id}\n"
            f"\tuco: {uco}\n"
            f"\tname: {name}\n"
        )

    def mark_failure(self, user_id):
        print(f"Failure: {user_id}")



class IPGenerator():
    def next_round(self):
        raise NotImplementedException()

    def init_ip(self):
        raise NotImplementedException()

    def next_ip(self):
        raise NotImplementedException()


class StaticIPGenerator(IPGenerator):
    def __init__(self, ip_addr):
        self.ip_addr = ip_addr

    def next_round(self):
        return False

    def next_ip(self):
        return self.ip_addr
    
    def init_ip(self):
        return self.ip_addr


class Worker():
    
    def __init__(self, uid_generator, ip_generator, sleep_timer):
        self.uid_generator = uid_generator
        self.ip_generator = ip_generator
        self.idc = IDChecker(ip_generator.init_ip())
        self.sleep_timer = sleep_timer
    
    def check(self):
        uid = self.uid_generator.fetch_id()
        if uid == None:
            return None
        try:
            xs = self.idc.request(uid)
        except EmptyResultError as e:
            self.uid_generator.mark_failure(uid)
            return uid
        for uco, name in xs:
            self.uid_generator.mark_success(uid, uco, name)
        return uid

    def run(self):
        while self.check() != None:
            if self.ip_generator.next_round():
                self.idc.rotate_ip(
                    self.ip_generator.next_ip()
                )
            sleep(self.sleep_timer)


if __name__ == '__main__':
    worker = Worker(
        TestGenerator(),
        StaticIPGenerator("0.0.0.0"),
        1
    )
    
    worker.run()
