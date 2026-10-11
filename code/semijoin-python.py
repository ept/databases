results = []
for person in people:
    for credit in composer_credits:
        if credit["person_id"] == person["person_id"]:
            results.append(person)
            break         # at most one row per person
