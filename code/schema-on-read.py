# Old documents have "name"; new ones have "first_name" and "last_name"
def display_name(person):
    if "first_name" in person:
        return person["first_name"] + " " + person["last_name"]
    else:
        return person["name"]
