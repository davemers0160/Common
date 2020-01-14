import pandas as pd
import os
from tqdm import tqdm
from multiprocessing.dummy import Pool as ThreadPool

annotation_file = "D:/Projects/object_detection_data/test-annotations-bbox.csv"
class_names = ["/m/01940j"]
download_dir = "D:/Projects/object_detection_data/"

data_type = "train"
# data_type = "test"

f = pd.read_csv(annotation_file)
u = f.loc[f['LabelName'].isin(class_names)]

commands = []

threads = 10
pool = ThreadPool(threads)

for idx in u.index:
    image_filename = u['ImageID'][idx] + ".jpg"
    command = "aws s3 --no-sign-request --only-show-errors cp s3://open-images-dataset/" + data_type + "/" + image_filename + " ."
    print(command)
    commands.append(command)


list(tqdm(pool.imap(os.system, commands), total = len(commands) ))

print('Done!')
pool.close()
pool.join()


bp = 1
