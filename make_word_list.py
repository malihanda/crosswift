
words = []
with open("word-list.csv") as f:
    for line in f.readlines():
        s = line.strip() + ";50"
        print(s)
        words.append(s)

with open("word-list.dict", "w") as f:
    text = "\n".join(words)
    f.write(text)