# This is to download the dataset and prepare it for training
# Make sure you have Kaggle API installed and configured
# Navigate to the URL of the kaggle, create new token and put it into /home/$(whoami)/.config/kaggle/kaggle.json
cp ~/Downloads/kaggle.json /home/$(whoami)/.config/kaggle
# Download the dataset
kaggle datasets download aswathrao/demand-forecasting -f test_nfaJ3J5.csv -p data/raw --unzip
kaggle datasets download aswathrao/demand-forecasting -f train_0irEZ2H.csv -p data/raw --unzip
# Rename the files
mv data/raw/test_nfaJ3J5.csv data/raw/test.csv
mv data/raw/train_0irEZ2H.csv data/raw/train.csv