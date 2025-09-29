# 1991년 12월 9일 생의 개인 타로 카드 계산

from datetime import datetime

def calculate_life_path_number(birth_date):
    """생년월일로 라이프 패스 넘버 계산"""
    # 모든 숫자를 더함
    total = sum(int(digit) for digit in birth_date.replace('-', ''))
    
    # 한 자리 수가 될 때까지 더함 (단, 11, 22, 33은 예외)
    while total > 9 and total not in [11, 22, 33]:
        total = sum(int(digit) for digit in str(total))
    
    return total

def get_tarot_card_from_life_path(life_path_number):
    """라이프 패스 넘버로 타로 카드 매핑"""
    tarot_mapping = {
        1: "The Magician",
        2: "The High Priestess", 
        3: "The Empress",
        4: "The Emperor",
        5: "The Hierophant",
        6: "The Lovers",
        7: "The Chariot",
        8: "Strength",
        9: "The Hermit",
        11: "Justice",
        22: "The Fool"
    }
    
    return tarot_mapping.get(life_path_number, "The Fool")

def get_birth_card_alternative(birth_date):
    """생년월일의 다른 계산 방법"""
    year, month, day = map(int, birth_date.split('-'))
    
    # 방법 1: 년도 + 월 + 일을 더하고 22로 나눈 나머지 (0~21)
    total = year + month + day
    card_number = (total % 22) + 1
    
    major_arcana = [
        "The Fool", "The Magician", "The High Priestess", "The Empress",
        "The Emperor", "The Hierophant", "The Lovers", "The Chariot",
        "Strength", "The Hermit", "Wheel of Fortune", "Justice",
        "The Hanged Man", "Death", "Temperance", "The Devil",
        "The Tower", "The Star", "The Moon", "The Sun",
        "Judgment", "The World"
    ]
    
    return major_arcana[card_number - 1]

# 1991년 12월 9일 계산
birth_date = "1991-12-09"
life_path = calculate_life_path_number(birth_date)
tarot_card = get_tarot_card_from_life_path(life_path)
birth_card = get_birth_card_alternative(birth_date)

print(f"🎂 생년월일: {birth_date}")
print(f"🔢 라이프 패스 넘버: {life_path}")
print(f"🎴 개인 타로 카드 (라이프 패스): {tarot_card}")
print(f"🎴 탄생 타로 카드 (계산법2): {birth_card}")

# 계산 과정 상세 출력
print(f"\n📊 계산 과정:")
print(f"1 + 9 + 9 + 1 + 1 + 2 + 0 + 9 = {sum(int(d) for d in birth_date.replace('-', ''))}")
print(f"3 + 2 = {life_path}")

# 탄생 카드 계산 과정
total = 1991 + 12 + 9
print(f"\n🎯 탄생 카드 계산:")
print(f"1991 + 12 + 9 = {total}")
print(f"{total} % 22 + 1 = {(total % 22) + 1}")
