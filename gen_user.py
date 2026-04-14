from faker import Faker
import random

fake = Faker(['en_US', 'fr_CA', 'en_IN', 'ko_KR', 'ja_JP'])

# map country → faker locale so the usernames match country
locale_map = {
    "United States": "en_US",
    "Canada": "fr_CA",
    "United Kingdom": "en_GB",
    "India": "en_IN",
    "South Korea": "ko_KR",
    "Japan": "ja_JP",
    "Australia": "en_AU"
}

# this is so it has a weighted distribution of the countries,
# otherwise it would be way too random, and a business goal that relied
# on location data, would have weird results like 1 or 2 per country etc.
locations = [
    "United States", "United States", "United States",
    "Canada", "United Kingdom",
    "India", "India",
    "South Korea",
    "Japan",
    "Australia"
]

# all the valid show_id 's that appear in show inserts.
show_ids = [
    169, 465, 82, 179, 180, 335, 2, 40, 204, 206, 216, 396, 527,
    555, 32, 106, 118, 166, 251, 491, 539, 565, 748, 29, 61, 158,
    164, 353, 429, 420, 523, 538, 554, 618, 663, 150, 157, 269, 427, 431, 1
]

for i in range(1, 51):
    location = random.choice(locations)

    locale = locale_map.get(location, "en_US")
    fake = Faker(locale)

    username = fake.user_name()
    email = fake.email()

    dob = fake.date_of_birth(minimum_age=18, maximum_age=50)
    gender = random.choice(['Male', 'Female', 'Other'])

    creation_date = fake.date_between(start_date='-3y', end_date='today')
    membership = random.choice(['Free', 'Premium'])

    print(f"""INSERT INTO Spring26_S008_T3_USER VALUES ({i}, '{username}', '{email}', DATE '{dob}', '{gender}', '{location}', DATE '{creation_date}', '{membership}');""")

# -----------
# WATCH LOG 
# -----------
print("\n-- WATCH_LOG INSERTS--\n")
for log_id in range(1000, 1100):
    user_ID = random.randint(1, 50)

    show_id = random.choice(show_ids)
    # in our tv show scripts we made it max 3 seasons per show
    # since this is random it'd still be incorrect if it prints 3 when a show only has 2, i guess manually correct that
    season_num = random.randint(1, 3)
    #i set max episodes per season to be 5
    episode_num = random.randint(1, 5)

    date = fake.date_between(start_date='-1y', end_date='today')

    # rewatch flag? first watch added twice to weigh it.
    Rewatch_Flag = random.choice(['First', 'First', 'Rewatch'])

    # random rating between 1.0 and 5.0
    rating = round(random.uniform(1.0, 5.0), 1)

    

    print(f"""INSERT INTO Spring26_S008_T3_WATCH_LOG VALUES ({log_id}, {user_ID}, {show_id}, {season_num}, {episode_num}, DATE '{date}', '{Rewatch_Flag}', {rating});""")
