import json
import os
import csv

STUDENTS_FILE = "students.json"

def load_students():
    if not os.path.exists(STUDENTS_FILE):
        return []
    try:
        with open(STUDENTS_FILE, 'r', encoding='utf-8') as file:
            return json.load(file)
    except (json.JSONDecodeError, IOError) as e:
        print(f"Ошибка при загрузке данных: {e}. Начинаем с пустого списка.")
        return []

def save_students(students):
    try:
        with open(STUDENTS_FILE, 'w', encoding='utf-8') as file:
            json.dump(students, file, ensure_ascii=False, indent=4)
        return True
    except IOError as e:
        print(f"Ошибка при сохранении данных: {e}")
        return False

def validate_age(age):
    try:
        age_int = int(age)
        if age_int <= 16:
            return False, None
        return True, age_int
    except ValueError:
        return False, None

def validate_grades(grades_str):
    if not grades_str.strip():
        return True, [] 
    parts = grades_str.split(',')
    grades = []
    for part in parts:
        try:
            grade = int(part.strip())
            if grade < 2 or grade > 5:
                print(f"Ошибка: оценка {grade} должна быть от 2 до 5")
                return False, None
            grades.append(grade)
        except ValueError:
            print(f"Ошибка: '{part.strip()}' не является числом")
            return False, None
    return True, grades

def add_student(students):
    print("\nДобавление студента")
    
    name = input("Введите имя студента: ").strip()
    if not name:
        print("Ошибка: имя не может быть пустым.")
        return
    
    while True:
        age_input = input("Введите возраст (>16): ").strip()
        valid_age, age = validate_age(age_input)
        if valid_age:
            break
        print("Ошибка: возраст должен быть целым числом больше 16. Попробуйте снова.")
    
    group = input("Введите группу: ").strip()
    if not group:
        print("Ошибка: группа не может быть пустой.")
        return
    
    while True:
        grades_input = input("Введите оценки через запятую (2-5, например: 4,5,3): ").strip()
        valid_grades, grades = validate_grades(grades_input)
        if valid_grades:
            break
        print("Ошибка: оценки должны быть числами от 2 до 5, разделёнными запятыми.")
    
    new_id = max([s["id"] for s in students], default=0) + 1
    students.append({
        "id": new_id,
        "name": name,
        "age": age,
        "group": group,
        "grades": grades
    })
    save_students(students)
    print(f" Студент '{name}' добавлен с ID {new_id}.")

def list_students(students):
    if not students:
        print("\n Список студентов пуст.")
        return
    print("\n" + "="*60)
    print(" СПИСОК СТУДЕНТОВ")
    print("="*60)
    for s in students:
        grades_str = ", ".join(map(str, s["grades"])) if s["grades"] else "нет оценок"
        avg = sum(s["grades"]) / len(s["grades"]) if s["grades"] else 0
        print(f"{s['id']}. {s['name']} | Возраст: {s['age']} | Группа: {s['group']}")
        print(f"   Оценки: {grades_str} | Средний балл: {avg:.2f}")
        print("-"*40)

def find_students(students):
    if not students:
        print("\n Список студентов пуст.")
        return
    query = input("\n Введите имя или группу для поиска: ").strip().lower()
    if not query:
        print("Ошибка: запрос не может быть пустым.")
        return
    
    found = [s for s in students if query in s["name"].lower() or query in s["group"].lower()]
    
    if found:
        print("\n" + "="*50)
        print(f" РЕЗУЛЬТАТЫ ПОИСКА (найдено: {len(found)})")
        print("="*50)
        for s in found:
            grades_str = ", ".join(map(str, s["grades"])) if s["grades"] else "нет оценок"
            avg = sum(s["grades"]) / len(s["grades"]) if s["grades"] else 0
            print(f"{s['id']}. {s['name']} | Группа: {s['group']}")
            print(f"   Оценки: {grades_str} | Средний балл: {avg:.2f}")
            print("-"*40)
    else:
        print(f" Студенты по запросу '{query}' не найдены.")

def average_grade(students):
    if not students:
        print("\n Список студентов пуст.")
        return
    
    try:
        sid = int(input("\n Введите ID студента для расчёта среднего балла: "))
    except ValueError:
        print("Ошибка: ID должен быть числом.")
        return
    
    for s in students:
        if s["id"] == sid:
            if not s["grades"]:
                print(f" У студента {s['name']} нет оценок.")
                return
            avg = sum(s["grades"]) / len(s["grades"])
            print(f"\n Студент: {s['name']}")
            print(f"   Оценки: {', '.join(map(str, s['grades']))}")
            print(f"   Средний балл: {avg:.2f}")
            if avg >= 4.5:
                print("    Отличник!")
            elif avg >= 3.5:
                print("    Хорошист")
            elif avg >= 2.5:
                print("    Троечник")
            else:
                print("    Нужно подтянуться")
            return
    print(f" Студент с ID {sid} не найден.")

def export_to_csv(students):
    if not students:
        print("\nНет данных для экспорта.")
        return
    
    try:
        with open("students.csv", 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["ID", "Имя", "Возраст", "Группа", "Оценки", "Средний балл"])
            for s in students:
                grades_str = ";".join(map(str, s["grades"])) if s["grades"] else ""
                avg = sum(s["grades"]) / len(s["grades"]) if s["grades"] else 0
                writer.writerow([s["id"], s["name"], s["age"], s["group"], grades_str, f"{avg:.2f}"])
        print("Данные успешно экспортированы в students.csv")
    except IOError as e:
        print(f" Ошибка при экспорте: {e}")

def delete_student(students):
    if not students:
        print("\n Список студентов пуст.")
        return
    
    list_students(students)
    try:
        sid = int(input("\n Введите ID студента для удаления: "))
    except ValueError:
        print("Ошибка: ID должен быть числом.")
        return
    
    for i, s in enumerate(students):
        if s["id"] == sid:
            confirm = input(f"Вы уверены, что хотите удалить студента '{s['name']}'? (да/нет): ").lower()
            if confirm == 'да' or confirm == 'yes':
                removed = students.pop(i)
                save_students(students)
                print(f" Студент '{removed['name']}' удалён.")
            else:
                print(" Удаление отменено.")
            return
    print(f" Студент с ID {sid} не найден.")

def main():
    students = load_students()
    print("="*60)
    print("    СИСТЕМА УЧЁТА СТУДЕНТОВ ")
    print("="*60)
    print(f"Загружено студентов: {len(students)}")
    
    while True:
        print("\n" + "="*40)
        print(" МЕНЮ:")
        print("1. Добавить студента")
        print("2. Показать всех студентов")
        print("3. Поиск студента")
        print("4. Средний балл студента")
        print("5. Экспорт в CSV")
        print("6. Удалить студента")
        print("7. Выход")
        print("="*40)
        
        choice = input("Выберите действие (1-7): ").strip()
        
        if choice == "1":
            add_student(students)
        elif choice == "2":
            list_students(students)
        elif choice == "3":
            find_students(students)
        elif choice == "4":
            average_grade(students)
        elif choice == "5":
            export_to_csv(students)
        elif choice == "6":
            delete_student(students)
        elif choice == "7":
            print("\n Вэход! Данные сохранены в students.json")
            break
        else:
            print("Неверный ввод. Пожалуйста, выберите число от 1 до 7.")

if __name__ == "__main__":
    main()
