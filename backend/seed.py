import datetime
import logging
import sys
from app.core.security import hash_password
from app.database import SessionLocal
from app.models import User, Category, Pet, AdoptionApplication, Favorite
from sqlalchemy import text

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def seed_data():
    db = SessionLocal()

    try:
        logger.info("0. Clearing old data and resetting IDs to 1...")
        db.execute(
            text('TRUNCATE TABLE "favorites", "adoption_application", "pet", "user" , "category" RESTART IDENTITY CASCADE;'))
        db.commit()

        logger.info("1. Creating categories...")

        cat_cat = Category(name="Cat")
        cat_dog = Category(name="Dog")
        cat_bird = Category(name="Bird")
        cat_fish = Category(name="Fish")
        cat_other = Category(name="Other")

        all_categories = [cat_cat, cat_dog, cat_bird, cat_fish, cat_other]
        db.add_all(all_categories)
        db.commit()

        for category in all_categories:
            db.refresh(category)
            logger.info(f"Created {category.__class__.__name__}: {category.id}")

        logger.info("2. Creating test users...")
        user_1 = User(
            username="bilgenur",
            email="bilge@hotmail.com",
            full_name="Bilge Nur Pala",
            role="admin"
        )
        user_1.password_hash = hash_password("Bilge1234")

        user_2 = User(
            username="daphenzz",
            email="seda@gmail.com",
            full_name="Sedanur Parmaksız",
            role="user"
        )
        user_2.password_hash = hash_password("Sedanur2002")

        user_3 = User(
            username="arjin",
            email="arjin@outlook.com",
            full_name="Arjin Özceylan",
            role="admin"
        )
        user_3.password_hash = hash_password("Arjin2026")

        all_users = [user_1,user_2,user_3]
        db.add_all(all_users)
        db.commit()

        for user in all_users:
            db.refresh(user)
            logger.info(f"Created {user.__class__.__name__}: {user.id}")


        logger.info("3. Creating pets...")

        pet_cf1 = Pet(
            name="Princess",
            species="cat",
            breed="Scottish Fold",
            age=1.0,
            gender="female",
            size="medium",
            energy_level="low",
            description="Found on the street. I took them under my protection after seeing them being attacked by stray"
                        " cats, as they were unable to defend themselves. They are very gentle, love being petted, and"
                        " enjoy being held. They have a very delicate personality. Internal and external parasite"
                        " treatments have been completed, and they are perfectly healthy. There is absolutely no fee"
                        " required for vaccinations or any other expenses. My only request is to find a responsible"
                        " family with sufficient financial means who will love and adopt them like their own child." ,
            photo_url="/uploads/pets/princess-cf1.png",
            adoption_fee=00.00,
            status="adopted",
            owner_id=user_1.id,
            category_id=cat_cat.id,
            is_approved=True
        )

        pet_cf2 = Pet(
            name="Pera",
            species="cat",
            breed="Van Cat",
            age=1.5,
            gender="female",
            size="small",
            energy_level="low",
            description="She is a 1.5-year-old female, a mix of British Shorthair and Van cat. She is very gentle and "
                        "house-trained. We are looking to rehome her because my mother has been diagnosed with chronic"
                        " bronchitis. I would be very happy if interested individuals could contact me.",
            photo_url="/uploads/pets/pera-cf2.png",
            adoption_fee=500.00,
            status="available",
            owner_id=user_1.id,
            category_id=cat_cat.id,
            is_approved=True
        )

        pet_cf3 = Pet(
            name="Blue",
            species="cat",
            breed="Exotic Shorthair",
            age=1.0,
            gender="female",
            size="small",
            energy_level="low",
            description="Blue is a gentle and healthy soul. I am looking for a family who will love and care for her "
                        "for a lifetime. I am looking for determined and responsible individuals to reach out. If you "
                        "do not have window screens in your home, please contact me only after having them installed.",
            photo_url="/uploads/pets/blue-cf3.png",
            adoption_fee=1000.00,
            status="available",
            owner_id=user_1.id,
            category_id=cat_cat.id,
            is_approved=True
        )

        pet_cf4 = Pet(
            name="Pepper",
            species="cat",
            breed="Tabby Cat",
            age=1.0,
            gender="female",
            size="large",
            energy_level="high",
            description="Our neutered, playful cat is looking for a new home. She has been with us for over 5 years, "
                        "but as the children are no longer interested and we struggle to find someone to care for her "
                        "during our vacations, we believe she will be happy in a new home. We will provide her along "
                        "with her litter box, litter, carrier, and even her food. She has no health issues and is a "
                        "very agile and playful little companion.",
            photo_url="/uploads/pets/pepper-cf4.png",
            adoption_fee=00.00,
            status="available",
            owner_id=user_1.id,
            category_id=cat_cat.id,
            is_approved=True
        )

        pet_cf5 = Pet(
            name="Olive",
            species="cat",
            breed="Tuxedo Cat",
            age=2.0,
            gender="female",
            size="large",
            energy_level="medium",
            description="Please provide a home for this innocent Olive; I am a foreigner and I am returning to my home"
                        " country, so I am looking for a home for my cat. I am moving away, and if I cannot find an"
                        " owner, I will unfortunately have to take her to a shelter. Please, for the sake of God, "
                        "help me so that my cat does not have to go to a shelter. She is a two-year-old spayed female.",
            photo_url="/uploads/pets/olive-cf5.png",
            adoption_fee=00.00,
            status="available",
            owner_id=user_2.id,
            category_id=cat_cat.id,
            is_approved=False
        )

        pet_cm1 = Pet(
            name="Atlas",
            species="cat",
            breed="Ginger Cat",
            age=0.2,
            gender="male",
            size="small",
            energy_level="high",
            description="Atlas is a 2-month-old male kitten who is eating solid food and is litter-box trained. He has"
                        " received detailed veterinary check-ups and his internal and external parasite treatments are"
                        " complete. He and his two siblings were abandoned in a trash container at my workplace when"
                        " they were still nursing babies. We took them under our care, and they grew up in a foster"
                        " home; his siblings have already found their forever homes, and now we are looking for a loving"
                        " family for Atlas who will treat him like their own child for the rest of his life. He is a"
                        " very social, playful, and affectionate little man who loves human company and purrs constantly.",
            photo_url="/uploads/pets/atlas-cm1.png",
            adoption_fee=00.00,
            status="pending",
            owner_id=user_1.id,
            category_id=cat_cat.id,
            is_approved=True
        )

        pet_cm2 = Pet(
            name="Coal",
            species="cat",
            breed="Bombay Cat",
            age=0.1,
            gender="male",
            size="small",
            energy_level="high",
            description="Coal is an approximately 1.5-month-old male kitten looking for his loving forever home. "
                        "He is an absolute sweetheart who loves spending time with people, being held, and playing. "
                        "He is very warm-hearted, friendly, and well-adjusted, getting along wonderfully with other "
                        "cats and children; he is a playful and affectionate little companion who will bring joy and "
                        "happiness to any environment. He is 1.5 months old, male, very loving, warm-hearted, playful, "
                        "energetic, well-socialized with other cats, excellent with children, and litter-box trained. "
                        "He will be adopted out in Istanbul only to those who have window screens installed and are "
                        "committed to being a forever family. Coal is not a toy, but a little soul to be loved for a "
                        "lifetime; we kindly ask that only responsible individuals who truly believe they can be his "
                        "family for life reach out. We will provide 24/7 support for any needs, and his toys and carrier "
                        "will be included. Thank you!",
            photo_url="/uploads/pets/coal-cm2.png",
            adoption_fee=00.00,
            status="available",
            owner_id=user_1.id,
            category_id=cat_cat.id,
            is_approved=True
        )

        pet_cm3 = Pet(
            name="Jasper",
            species="cat",
            breed="Persian Cat",
            age=2.0,
            gender="male",
            size="large",
            energy_level="medium",
            description="My friend’s cat, whom he rescued from the street and adopted about 8 months ago, is looking for"
                        " a new home. Due to work commitments, my friend is frequently away and cannot provide the care"
                        " the cat needs, so we are looking for someone who can offer a better environment. He is a"
                        " 2-year-old Persian cat and has been neutered. All of his teeth had to be extracted due to "
                        "decay, but he is otherwise healthy. We will also provide all of his belongings with him.",
            photo_url="/uploads/pets/jasper-cm3.png",
            adoption_fee=300.00,
            status="available",
            owner_id=user_1.id,
            category_id=cat_cat.id,
            is_approved=True
        )

        pet_cm4 = Pet(
            name="Leo",
            species="cat",
            breed="Siamese Cat",
            age=4.0,
            gender="male",
            size="small",
            energy_level="low",
            description="He needs a loving family and will be given away with all his belongings.",
            photo_url="/uploads/pets/leo-cm4.png",
            adoption_fee=00.00,
            status="available",
            owner_id=user_2.id,
            category_id=cat_cat.id,
            is_approved=True
        )

        pet_cm5 = Pet(
            name="Teddy",
            species="cat",
            breed="Tabby Cat",
            age=6.0,
            gender="male",
            size="medium",
            energy_level="low",
            description="He is a 6-year-old cat who stays indoors but occasionally goes outside. He is very meticulous "
                        "about his litter box and loves being petted. He is fully vaccinated, microchipped, "
                        "and neutered.",
            photo_url="/uploads/pets/teddy-cm5.png",
            adoption_fee=00.00,
            status="available",
            owner_id=user_1.id,
            category_id=cat_cat.id,
            is_approved=True
        )


        pet_df1 = Pet(
            name="Shila",
            species="dog",
            breed="German Shepherd",
            age=1,
            gender="female",
            size="large",
            energy_level="medium",
            description="Shila was rescued a month ago with her six puppies, but sadly, she lost four of them. Her two "
                        "surviving puppies have found their homes, and now Shila is in a foster home, searching for her"
                        " forever family. She is a gentle, affectionate, and social dog who gets along well with other"
                        " dogs and is not aggressive. Since she does not yet know how to walk on a leash, a home with a"
                        " garden would be ideal for her. She is fully vaccinated, microchipped, and has a passport."
                        " She will be adopted for free, with no fees involved, provided that the new owner is over 25"
                        " years old, responsible, and prepared to sign an adoption form. We are looking for a forever"
                        " family who will be committed to her for life.",
            photo_url="/uploads/pets/shila-df1.png",
            adoption_fee=00.00,
            status="adopted",
            category_id=cat_dog.id,
            owner_id=user_2.id,
            is_approved=True
        )

        pet_df2 = Pet(
            name="Elsa",
            species="dog",
            breed="Labrador",
            age=2,
            gender="female",
            size="medium",
            energy_level="high",
            description="I rescued Elsa from a shelter in March 2025. She is currently being cared for at a boarding "
                        "facility that I trust, but Elsa is a soul who was abandoned at a shelter after being raised in"
                        " a home; her eyes and heart are always searching for human companionship. We are looking for a"
                        " warm-hearted person we can trust and who accepts our requirement for follow-ups. Elsa is a"
                        " female, spayed, and fully vaccinated.",
            photo_url="/uploads/pets/elsa-df2.png",
            adoption_fee=1000.00,
            status="available",
            category_id=cat_dog.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_df3 = Pet(
            name="Yula",
            species="dog",
            breed="Collie",
            age=1,
            gender="female",
            size="small",
            energy_level="high",
            description="Yula is a one-year-old, affectionate, and playful dog who is currently in need of a forever "
                        "home. Although I adopted her and she is registered under my name, I am unable to keep her "
                        "because she does not get along with my cats, and I am currently facing housing issues that "
                        "make it difficult to care for all my animals. She is well-behaved, house-trained, and "
                        "accustomed to a home environment. I am looking for a responsible, forever family in the city "
                        "who can provide her with a loving indoor home. The microchip will be transferred, and adoption "
                        "is subject to regular follow-ups and veterinary check-ups, as I would like to stay in touch "
                        "and occasionally visit her. Thank you.",
            photo_url="/uploads/pets/yula-df3.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_dog.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_df4 = Pet(
            name="Luna",
            species="dog",
            breed="Husky",
            age=6,
            gender="female",
            size="large",
            energy_level="low",
            description="She was sent to a shelter; she is a very sweet, delicate, and noble girl. If someone adopts "
                        "her, I will always cover her food expenses. I am moving to another city for work, and my "
                        "current circumstances are not suitable, which breaks my heart. She is spayed, and I am looking"
                        " for a loving home for her. I would be very happy if interested individuals could contact me.",
            photo_url="/uploads/pets/luna-df4.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_dog.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_df5 = Pet(
            name="Lucy",
            species="dog",
            breed="English Setter",
            age=2,
            gender="female",
            size="large",
            energy_level="medium",
            description="This beautiful 2-year-old girl was abandoned by her family. She is well-adjusted, gets along "
                        "well with other cats and dogs, and has a balanced temperament. We will respond to those who "
                        "have previous dog experience and provide a short introduction about themselves.",
            photo_url="/uploads/pets/lucy-df5.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_dog.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_dm1 = Pet(
            name="Merle",
            species="dog",
            breed="French Bulldog",
            age=5,
            gender="male",
            size="small",
            energy_level="low",
            description="Due to our child’s allergies, we are looking for a new home for our dog whom we have cared for"
                        " for 5 years. We can arrange the handover in Adana or Mersin. They are fully vaccinated and "
                        "have no health issues. They are extremely gentle, quiet, and never bark or bite. They are "
                        "house-trained and are somewhat lazy; short 5-minute walks twice a day are usually sufficient.",
            photo_url="/uploads/pets/merle-dm1.png",
            adoption_fee=00.00,
            status="pending",
            category_id=cat_dog.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_dm2 = Pet(
            name="Max",
            species="dog",
            breed="Chihuahua",
            age=5,
            gender="male",
            size="small",
            energy_level="medium",
            description="Found on the street in 2021 when he was one year old, our friend is healthy, fully vaccinated, "
                        "and well-cared for. He is a natural protector of his territory; it takes him 2-3 visits to feel"
                        " comfortable with strangers. He loves playing and going for walks, and if you have a garden, "
                        "he enjoys running around within its boundaries—he doesn't wander off even if the gate is left "
                        "open. He follows commands but may be reluctant to head home immediately after a walk. He is "
                        "very affectionate with his owner, loves to cuddle, enjoys being brushed, and gets excited when"
                        " he sees his leash, which he lets you put on easily. He is not a picky eater and loves drinking"
                        " milk. Please note that he may get motion sickness during car rides if he cannot look out the"
                        " window, and he has never traveled in a carrier. We are looking for someone who can give him"
                        " the attention and love he deserves.",
            photo_url="/uploads/pets/max-dm2.png",
            adoption_fee=400.00,
            status="available",
            category_id=cat_dog.id,
            owner_id=user_2.id,
            is_approved=False
        )

        pet_dm3 = Pet(
            name="Bruno",
            species="dog",
            breed="Crossbreed",
            age=2,
            gender="male",
            size="medium",
            energy_level="medium",
            description="We rescued this 2-year-old, 9 kg mixed-breed boy from the shelter (the 3rd photo shows him in "
                        "the shelter). He is very gentle and intelligent. We are looking for an experienced family who "
                        "will never abandon him again. Adoption is completely free of charge—we do not request any "
                        "money for food, vaccines, or other expenses. Our priority is for homes in or near Istanbul.",
            photo_url="/uploads/pets/bruno-dm3.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_dog.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_dm4 = Pet(
            name="Cedar",
            species="dog",
            breed="Cane Corso",
            age=3,
            gender="male",
            size="large",
            energy_level="high",
            description="Cedar is a 3-year-old neutered male Cane Corso. Behind his imposing appearance lies a loving "
                        "teddy bear. We are currently in Ankara, and we are looking for a forever home for him in cities"
                        " such as Ankara, Izmir, Bursa, Mugla, Samsun, Corum, Manisa, Mersin, Istanbul, Balikesir, Ordu,"
                        " or Eskisehir. All he wants is a little attention and love; he is a giant teddy bear who will"
                        " come to you just to be petted. We are looking for a home with a spacious garden where he can "
                        "run and play freely, where his walks will never be neglected, and where he will never be "
                        "abandoned or kept on a chain. Adoption will be processed through a follow-up procedure and a "
                        "contract protecting animal rights, and we are looking for a stable family over the age of 25 "
                        "who can take on the emotional and financial responsibility for him.",
            photo_url="/uploads/pets/cedar-dm4.png",
            adoption_fee=600.00,
            status="available",
            category_id=cat_dog.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_dm5 = Pet(
            name="Cloud",
            species="dog",
            breed="Golden Retriever",
            age=3,
            gender="male",
            size="large",
            energy_level="low",
            description="He is a 3-year-old male, fluffy, snow-white coat of a Golden Retriever, resembling a cloud. "
                        "He is one of the dogs currently under protective care in Ankara, and we are looking for a "
                        "foster or forever home for him in Ankara or surrounding provinces. He has a very gentle, "
                        "non-aggressive nature, but he is also an excellent guardian who will alert you when strangers "
                        "approach. He would be happiest in a spacious area where he can run and play freely, "
                        "and he must not be kept on a chain. Please reach out with an introduction message; "
                        "we will not respond to other types of messages.",
            photo_url="/uploads/pets/cloud-dm5.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_dog.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_b1 = Pet(
            name="Pearl",
            species="bird",
            breed="Budgie",
            age=1.5,
            gender="female",
            size="small",
            energy_level="high",
            description="She is a 1.5-year-old, adorable white female budgie. She is very tame and comfortable "
                        "being handled. She is currently waiting for a new, loving owner. Please reach out "
                        "if you are interested.",
            photo_url="/uploads/pets/pearl-b1.png",
            adoption_fee=00.00,
            status="adopted",
            category_id=cat_bird.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_b2 = Pet(
            name="Sunny",
            species="bird",
            breed="Cockatiel",
            age=2,
            gender="male",
            size="small",
            energy_level="medium",
            description="This gentle and hand-tamed 2-year-old cockatiel loves to whistle and enjoys spending time "
                        "outside of the cage with his human companion..",
            photo_url="/uploads/pets/sunny-b2.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_bird.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_b3 = Pet(
            name="Sky",
            species="bird",
            breed="parrot",
            age=1,
            gender="male",
            size="small",
            energy_level="high",
            description="This energetic and friendly 1-year-old parrot is looking for a loving home where he can chirp "
                        "and play all day.",
            photo_url="/uploads/pets/sky-b3.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_bird.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_b4 = Pet(
            name="Rio",
            species="bird",
            breed="Lovebird",
            age=0.5,
            gender="male",
            size="small",
            energy_level="high",
            description="A vibrant and affectionate 6-month-old lovebird, ready to bring joy and personality to a new,"
                        " caring family.",
            photo_url="/uploads/pets/rio-b4.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_bird.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_b5 = Pet(
            name="Luna",
            species="bird",
            breed="Canary",
            age=0.5,
            gender="female",
            size="small",
            energy_level="low",
            description="This beautiful, young canary has a wonderful singing voice and would make a peaceful, cheerful "
                        "addition to any home.",
            photo_url="/uploads/pets/luna-b5.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_bird.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_f1 = Pet(
            name="Bubbles",
            species="fish",
            breed="Goldfish",
            age=1,
            gender="female",
            size="small",
            energy_level="low",
            description="This calm and beautiful 1-year-old goldfish is looking for a spacious new tank to swim in.",
            photo_url="/uploads/pets/bubbles-f1.png",
            adoption_fee=00.00,
            status="pending",
            category_id=cat_fish.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_f2 = Pet(
            name="Finny",
            species="fish",
            breed="Betta fish",
            age=0.5,
            gender="male",
            size="small",
            energy_level="low",
            description="With his vibrant colors and elegant fins, this 6-month-old betta fish is ready to be the "
                        "centerpiece of a peaceful aquarium.",
            photo_url="/uploads/pets/finny-f2.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_fish.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_f3 = Pet(
            name="Flash",
            species="fish",
            breed="Neon tetra",
            age=1,
            gender="male",
            size="small",
            energy_level="low",
            description="This active and schooling 1-year-old neon tetra would love to join a community tank and add a "
                        "splash of color to your home.",
            photo_url="/uploads/pets/flash-f3.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_fish.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_f4 = Pet(
            name="Shadow",
            species="fish",
            breed="Molly",
            age=0.8,
            gender="male",
            size="small",
            energy_level="low",
            description="A hardy and social 8-month-old molly, perfect for both beginners and experienced fish keepers "
                        "looking for a cheerful companion.",
            photo_url="/uploads/pets/shadow-f4.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_fish.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_f5 = Pet(
            name="Goldie",
            species="fish",
            breed="Angelfish",
            age=2,
            gender="female",
            size="small",
            energy_level="low",
            description="This graceful and distinctive 2-year-old angelfish is looking for a large, well-maintained "
                        "tank to showcase its majestic swimming style.",
            photo_url="/uploads/pets/goldie-f5.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_fish.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_o1 = Pet(
            name="Nibbles",
            species="other",
            breed="Hamster",
            age=0.5,
            gender="male",
            size="small",
            energy_level="high",
            description="This curious and active 6-month-old hamster is looking for a cozy home with plenty of space to "
                        "burrow and play.",
            photo_url="/uploads/pets/nibbles-o1.png",
            adoption_fee=00.00,
            status="adopted",
            category_id=cat_other.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_o2 = Pet(
            name="Cotton",
            species="other",
            breed="Rabbit",
            age=1,
            gender="female",
            size="medium",
            energy_level="high",
            description="This soft and gentle 1-year-old rabbit loves to hop around and is searching for a loving "
                        "family that can provide plenty of hay and affection.",
            photo_url="/uploads/pets/cotton-o2.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_other.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_o3 = Pet(
            name="Peanut",
            species="other",
            breed="Guinea pig",
            age=0.8,
            gender="female",
            size="small",
            energy_level="high",
            description="This social and vocal 8-month-old guinea pig is a perfect companion who enjoys snacking on"
                        " fresh vegetables and cuddling with his owners.",
            photo_url="/uploads/pets/peanut-o3.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_other.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_o4 = Pet(
            name="Mia",
            species="other",
            breed="Chicken",
            age=1,
            gender="female",
            size="small",
            energy_level="high",
            description="TThis friendly and calm 1-year-old hen is looking for a safe, spacious coop with outdoor "
                        "access where she can spend her days foraging happily.",
            photo_url="/uploads/pets/mia-o4.png",
            adoption_fee=700.00,
            status="available",
            category_id=cat_other.id,
            owner_id=user_1.id,
            is_approved=True
        )

        pet_o5 = Pet(
            name="Shelly",
            species="other",
            breed="Turtle",
            age=3,
            gender="male",
            size="small",
            energy_level="low",
            description="TThis peaceful and observant 3-year-old turtle is looking for a new owner who can provide "
                        "a clean, well-equipped habitat and the long-term care she needs.",
            photo_url="/uploads/pets/shelly-o5.png",
            adoption_fee=00.00,
            status="available",
            category_id=cat_other.id,
            owner_id=user_2.id,
            is_approved=False
        )

        all_pets=[pet_cf1,pet_cf2,pet_cf3,pet_cf4,pet_cf5,pet_cm1,pet_cm2,pet_cm3,pet_cm4,pet_cm5,
                  pet_df1,pet_df2,pet_df3,pet_df4,pet_df5,pet_dm1,pet_dm2,pet_dm3,pet_dm4,pet_dm5,
                  pet_b1,pet_b2,pet_b3,pet_b4,pet_b5,
                  pet_f1,pet_f2,pet_f3,pet_f4,pet_f5,
                  pet_o1,pet_o2,pet_o3,pet_o4,pet_o5]
        db.add_all(all_pets)
        db.commit()

        for pet in all_pets:
            db.refresh(pet)
            logger.info(f"Added pet {pet.name} with id {pet.id}")

        logger.info("4. Creating adoption applications and favorites...")

        adap_a1 = AdoptionApplication(
            user_id=user_3.id,
            pet_id=pet_cf1.id,
            message="I can take great care of Princess, I have experience with cats.",
            status="approved",
            created_at=datetime.datetime(2026,5,10)
        )

        adap_a2 = AdoptionApplication(
            user_id=user_3.id,
            pet_id=pet_df1.id,
            message="Shila is a very sweet girl, i can take care of her",
            status="approved",
            created_at=datetime.datetime(2026,2,23)
        )

        adap_a3 = AdoptionApplication(
            user_id=user_3.id,
            pet_id=pet_b1.id,
            message="I love birds.",
            status="approved",
            created_at=datetime.datetime(2026,1,12)
        )

        adap_c= AdoptionApplication(
            user_id=user_3.id,
            pet_id=pet_o1.id,
            message="I love hamsters. Nibbles is a very cool name",
            status="completed",
            created_at=datetime.datetime(2026,3,11)
        )

        adap_p1 = AdoptionApplication(
            user_id=user_3.id,
            pet_id=pet_cm1.id,
            message="I love cats, I have experience with cats.",
            status="pending",
            created_at=datetime.datetime(2026,7,5)
        )

        adap_p2 = AdoptionApplication(
            user_id=user_3.id,
            pet_id=pet_dm1.id,
            message="I love dogs, I have experience with dogs.",
            status="pending",
            created_at=datetime.datetime(2025,12,31)
        )

        adap_p3 = AdoptionApplication(
            user_id=user_3.id,
            pet_id=pet_f1.id,
            message="I love fish.",
            status="pending",
            created_at=datetime.datetime(2026,4,1)
        )

        adap_r1= AdoptionApplication(
            user_id=user_3.id,
            pet_id=pet_o2.id,
            message="I love rabbits.",
            status="rejected",
            created_at=datetime.datetime(2025,11,23)
        )

        adap_r2= AdoptionApplication(
            user_id=user_3.id,
            pet_id=pet_cm5.id,
            message="I love cats, I can take care of him",
            status="rejected",
            created_at=datetime.datetime(2025,10,10)
        )

        all_adapts = [adap_a1,adap_a2,adap_a3,adap_c,adap_p1,adap_p2,adap_p3,adap_r1,adap_r2]
        db.add_all(all_adapts)
        db.commit()

        fav_1=Favorite(user_id=user_3.id,pet_id=pet_df1.id)
        fav_2=Favorite(user_id=user_3.id,pet_id=pet_b1.id)
        fav_3=Favorite(user_id=user_1.id,pet_id=pet_cm4.id)
        fav_4=Favorite(user_id=user_1.id,pet_id=pet_df1.id)
        fav_5=Favorite(user_id=user_2.id,pet_id=pet_o1.id)
        fav_6=Favorite(user_id=user_2.id,pet_id=pet_cf2.id)

        all_favs=[fav_1,fav_2,fav_3,fav_4,fav_5,fav_6]
        db.add_all(all_favs)
        db.commit()

        logger.info("Seeding Successful!")

    except Exception:
        logger.exception("Seeding failed, rolling back")
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    logger.info("Starting the seed process...")
    try:
        seed_data()
    except Exception:
        sys.exit(1)