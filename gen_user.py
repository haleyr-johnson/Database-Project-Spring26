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