import requests
import random
from faker import Faker

fake = Faker()

BASE_URL = "https://api.tvmaze.com/shows"
NUM_SHOWS = 40

# ---------------------------------------------
# STORAGE (CRITICAL for keeping fk's consistent)
# ---------------------------------------------
user_ids = list(range(1000, 1050))
show_ids = []
episode_keys = []   # (show_id, season, episode)
log_ids = []
review_ids = []

# -----------------
# USERS
# -----------------

print("-- USERS --")

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

for i in user_ids:
    location = random.choice(locations)
    fake_local = Faker(locale_map.get(location, "en_US"))

    username = fake_local.user_name()
    email = f"{username}@{fake_local.free_email_domain()}"

    dob = fake_local.date_of_birth(minimum_age=18, maximum_age=50)
    gender = random.choice(['Male', 'Female', 'Other'])

    creation_date = fake_local.date_between(start_date='-3y', end_date='today')
    membership = random.choice(['Free', 'Premium'])

    print(f"""INSERT INTO Spring26_S008_T3_USER VALUES ({i}, '{username}', '{email}', DATE '{dob}', '{gender}', '{location}', DATE '{creation_date}', '{membership}');""")


# -----------------------------
# TV SHOWS
# -----------------------------
print("\n-- TV SHOWS --")

country_languages = {
    "United States": ["English"],
    "United Kingdom": ["English"],
    "Canada": ["English", "French"],
    "Spain": ["Spanish"],
    "France": ["French"],
    "Germany": ["German"],
    "Japan": ["Japanese"],
    "South Korea": ["Korean"],
    "India": ["Hindi", "English"],
    "Mexico": ["Spanish"],
    "Brazil": ["Portuguese"]
}

status_map = {
    "Ended": "Completed",
    "Running": "Ongoing",
    "In Development": "Upcoming",
    "To Be Determined": "Upcoming",
    "Canceled": "Completed",
    "Pilot": "Upcoming"
}

faker_language_pool = [
    "English", "Spanish", "French", "German",
    "Japanese", "Korean", "Hindi", "Portuguese", "Italian"
]

def safe_str(value, fallback=None):
    if value is None:
        value = fallback if fallback else fake.word()
    return "'" + str(value).replace("'", "''") + "'"

def safe_runtime(value):
    return str(value) if value else str(random.choice([22,30,45,60]))

def safe_date(value):
    return f"'{value}'" if value else f"'{fake.date_between(start_date='-20y', end_date='today')}'"


# GET POPULAR SHOWS
all_shows = []
for page in range(0, 3):
    all_shows.extend(requests.get(f"{BASE_URL}?page={page}").json())

all_shows = [s for s in all_shows if s["rating"]["average"] is not None]
all_shows.sort(key=lambda x: x["rating"]["average"], reverse=True)

shows = all_shows[:NUM_SHOWS]

for show in shows:
    show_id = show["id"]
    show_ids.append(show_id)

    title = safe_str(show["name"])

    country = "Unknown"
    if show["network"] and show["network"]["country"]:
        country = show["network"]["country"]["name"]

    start_year = show["premiered"][:4] if show["premiered"] else fake.year()
    raw_status = show["status"]

    mapped_status = status_map.get(raw_status, "Upcoming")  
    # default fallback (safe choice)

    status = safe_str(mapped_status)

    print(f"INSERT INTO Spring26_S008_T3_TV_SHOW VALUES ({show_id}, {title}, {safe_str(country)}, {start_year}, {status});")

    # ---------------- GENRES ----------------
    for genre in show["genres"]:
        print(f"INSERT INTO Spring26_S008_T3_TV_SHOW_GENRE VALUES ({show_id}, {safe_str(genre)});")

    # ---------------- LANGUAGES ----------------
    langs = set()

    if show["language"]:
        langs.add(show["language"])

    if country in country_languages:
        langs.update(country_languages[country])

        if random.random() < 0.3:
            langs.add(random.choice(country_languages[country]))
    else:
        if random.random() < 0.3:
            langs.add(random.choice(faker_language_pool))

    for lang in langs:
        print(f"INSERT INTO Spring26_S008_T3_TV_SHOW_LANGUAGE VALUES ({show_id}, {safe_str(lang)});")

    # ---------------- PLATFORMS ----------------
    platforms = ["Netflix","Hulu","Amazon Prime","Disney+","HBO Max"]
    for p in random.sample(platforms, random.randint(1,3)):
        print(f"INSERT INTO Spring26_S008_T3_TV_SHOW_PLATFORM VALUES ({show_id}, {safe_str(p)});")

    # ---------------- SEASONS ----------------
    seasons = requests.get(f"{BASE_URL}/{show_id}/seasons").json()[:3]

    for season in seasons:
        season_num = season["number"]
        release_year = season["premiereDate"][:4] if season["premiereDate"] else start_year

        print(f"INSERT INTO Spring26_S008_T3_SEASON VALUES ({show_id}, {season_num}, {release_year});")

    # ---------------- EPISODES ----------------
    episodes = requests.get(f"{BASE_URL}/{show_id}/episodes").json()

    season_map = {}
    for ep in episodes:
        season_map.setdefault(ep["season"], []).append(ep)

    valid_seasons = {season["number"] for season in seasons}

    for season_num, eps in season_map.items():
        if season_num not in valid_seasons:
            continue  # skip invalid seasons

        eps = eps[:5]

        for ep in eps:
            ep_num = ep["number"] if ep["number"] else 1
            ep_title = safe_str(ep["name"], fallback="Episode")

            runtime = safe_runtime(ep["runtime"])
            airdate = safe_date(ep["airdate"])

            print(f"""INSERT INTO Spring26_S008_T3_EPISODE VALUES ({show_id}, {season_num}, {ep_num}, {ep_title}, {runtime}, {airdate});""")

            episode_keys.append((show_id, season_num, ep_num))


# -----------------------------
# WATCHLIST
# -----------------------------
print("\n-- WATCHLIST --")

watchlist_id = 2000
seen = set()

while watchlist_id <= 2050:
    u = random.choice(user_ids)
    s = random.choice(show_ids)

    if (u, s) not in seen:
        seen.add((u, s))
        print(f"INSERT INTO Spring26_S008_T3_WATCHLIST VALUES ({watchlist_id}, {u}, {s}, DATE '{fake.date_between(start_date='-2y', end_date='today')}');")
        watchlist_id += 1


# -----------------------------
# WATCH LOG
# -----------------------------
print("\n-- WATCH_LOG --")

for i in range(3000, 3100):
    user = random.choice(user_ids)
    show_id, season, ep = random.choice(episode_keys)

    log_ids.append(i)

    Rewatch_Flag = 'Rewatch' if random.random() < 0.3 else 'First'

    print(f"""INSERT INTO Spring26_S008_T3_WATCH_LOG VALUES ({i}, {user}, {show_id}, {season}, {ep}, DATE '{fake.date_between(start_date=creation_date, end_date='today')}', '{Rewatch_Flag}', {round(random.uniform(1,5),1)});""")


# -----------------------------
# REVIEW
# -----------------------------
print("\n-- REVIEW --")

for i in range(4000, 4050):
    log = random.choice(log_ids)
    user = random.choice(user_ids)

    review_ids.append(i)

    print(f"""INSERT INTO Spring26_S008_T3_REVIEW VALUES ({log}, {i}, {user}, '{fake.sentence()}', DATE '{fake.date_between(start_date=creation_date, end_date='today')}');""")


# -----------------------------
# FOLLOWS
# -----------------------------
print("\n-- FOLLOWS --")

seen = set()
for _ in range(50):
    a = random.choice(user_ids)
    b = random.choice(user_ids)

    if a != b and (a,b) not in seen:
        seen.add((a,b))
        print(f"INSERT INTO Spring26_S008_T3_FOLLOWS VALUES ({a}, {b});")


# -----------------------------
# REVIEW_INTERACTION
# -----------------------------
print("\n-- REVIEW_INTERACTION --")

interaction_id = 5000
interaction_keys = []

for _ in range(50):
    r = random.choice(review_ids)
    u = random.choice(user_ids)

    print(f"INSERT INTO Spring26_S008_T3_REVIEW_INTERACTION VALUES ({r}, {interaction_id}, {u}, DATE '{fake.date_between(start_date='-1y', end_date='today')}');")

    interaction_keys.append((r, interaction_id))
    interaction_id += 1


# -----------------------------
# LIKE + COMMENT
# -----------------------------
print("\n-- LIKE / COMMENT --")

for (r, i) in interaction_keys:
    if random.random() < 0.5:
        print(f"INSERT INTO Spring26_S008_T3_LIKE VALUES ({r}, {i});")
    else:
        print(f"INSERT INTO Spring26_S008_T3_COMMENT VALUES ({r}, {i}, '{fake.sentence()}');")