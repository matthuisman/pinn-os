import os, json

URL_BASE = "http://raw.githubusercontent.com/matthuisman/pinn-os/master/{folder}/{file}"
OUTPUT = "staging.json"

MAP = {
    "os_info": "os.json",
    "partitions_info": "partitions.json",
    "partition_setup": "partition_setup.sh",
    "icon": "{folder}.png",
    "marketing_info": "marketing.tar",
}

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)

DATA = {'os_list': []}

for folder in os.listdir(dname):
    folder_path = os.path.join(dname, folder)
    if not os.path.isdir(folder_path):
        continue

    files = os.listdir(folder_path)
    if "os.json" not in files:
        continue

    with open(os.path.join(folder_path, "os.json"), "r", encoding='utf8') as f:
        system = json.loads(f.read())

    with open(os.path.join(folder_path, "partitions.json"), "r", encoding='utf8') as f:
        partitions = json.loads(f.read())['partitions']

    system['nominal_size'] = 0
    for partition in partitions:
        system['nominal_size'] += int(partition.get("partition_size_nominal", 0))

    system['os_name'] = system.pop('name')

    for key in MAP:
        file_name = MAP[key].format(folder=folder)
        if file_name in files:
            system[key] = URL_BASE.format(folder=folder, file=file_name)
        else:
            print("{folder} missing {file}".format(folder=folder, file=file_name))

    if "os_list.json" in files:
        with open(os.path.join(folder_path, "os_list.json"), "r", encoding='utf8') as f:
            system.update(json.loads(f.read()))

    DATA['os_list'].append(system)

with open(OUTPUT, 'w', encoding='utf8') as f:
    f.write(json.dumps(DATA, indent=4, separators=(',', ': '), ensure_ascii=False))