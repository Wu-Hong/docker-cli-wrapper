import re
def fuzzyfinder(user_input, collection):
    suggestions = []
    pattern = '.*?'.join(user_input)    # Converts 'djm' to 'd.*?j.*?m'
    regex = re.compile(pattern)         # Compiles a regex.
    for item in collection:
        match = regex.search(item)      # Checks if the current item matches the regex.
        if match:
            suggestions.append((len(match.group()), match.start(), item))
    return [x for _, _, x in sorted(suggestions)]

if __name__ == "__main__":
    import sys
    raw_collection = eval(sys.argv[1]).strip()
    keyword = eval(sys.argv[2]).strip()
    collection = [item.strip() for item in raw_collection.split(sep=" ") if item.strip()]
    for result in fuzzyfinder(keyword, collection):
        print(result)
