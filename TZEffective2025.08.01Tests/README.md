# README для тестов приложения Todo

Данный файл содержит комплексные unit-тесты для основных компонентов приложения,
построенного на архитектуре VIPER. Тесты покрывают все ключевые модули и сервисы.

## СТРУКТУРА ТЕСТОВ:

### 1. TodoItemViewModelTests
- **testInitWithTodoItem**: Проверяет корректную инициализацию модели из Core Data объекта
- **testInitWithParameters**: Проверяет создание модели с заданными параметрами

### 2. CoreDataServiceTests
- **testCreateTodo**: Проверяет создание новой задачи в Core Data
- **testFetchTodos**: Проверяет получение списка задач с сортировкой по дате создания
- **testUpdateTodo**: Проверяет обновление существующей задачи
- **testDeleteTodo**: Проверяет удаление задачи
- **testToggleTodoCompletion**: Проверяет переключение статуса выполнения задачи

### 3. TodoListInteractorTests
- **testLoadTodosFromCoreData**: Проверяет загрузку задач из Core Data при повторном запуске
- **testLoadTodosFromAPI**: Проверяет загрузку задач из API при первом запуске
- **testSearchTodosWithQuery**: Проверяет поиск задач по запросу
- **testSearchTodosWithEmptyQuery**: Проверяет поиск при пустом запросе (возвращает все задачи)
- **testToggleTodoCompletion**: Проверяет переключение статуса выполнения задачи
- **testDeleteTodo**: Проверяет удаление задачи
- **testUpdateTodo**: Проверяет обновление задачи в локальном массиве

### 4. DetailTodoInteractorTests
- **testLoadTodoWithExistingTodo**: Проверяет загрузку существующей задачи для редактирования
- **testLoadTodoWithNilTodo**: Проверяет загрузку пустой формы для создания новой задачи
- **testSaveTodoWithExistingTodo**: Проверяет сохранение изменений в существующей задаче
- **testSaveTodoWithNewTodo**: Проверяет создание новой задачи

### 5. TodoListPresenterTests
- **testViewDidLoad**: Проверяет инициализацию при загрузке представления
- **testAddNewTodo**: Проверяет открытие экрана создания новой задачи
- **testEditTodo**: Проверяет открытие экрана редактирования задачи
- **testShareTodo**: Проверяет функционал поделиться задачей
- **testDeleteTodo**: Проверяет удаление задачи
- **testSearchTextChanged**: Проверяет обработку изменений в поисковой строке
- **testTodoToggled**: Проверяет переключение статуса задачи
- **testUpdateTodoAfterEdit**: Проверяет обновление списка после редактирования
- **testDidLoadTodos**: Проверяет отображение загруженных задач
- **testDidReceiveError**: Проверяет отображение ошибок

### 6. DetailTodoPresenterTests
- **testViewDidLoad**: Проверяет инициализацию при загрузке представления
- **testBackButtonTapped**: Проверяет сохранение при нажатии кнопки "Назад"
- **testBackButtonTappedWithEmptyTitleShouldShowError**: Проверяет валидацию пустого заголовка
- **testBackButtonTappedWithEmptyFieldsShouldClose**: Проверяет закрытие при пустых полях
- **testDidLoadTodo**: Проверяет отображение загруженной задачи
- **testDidSaveTodo**: Проверяет обработку успешного сохранения

## ОСОБЕННОСТИ РЕАЛИЗАЦИИ:

- Все тесты используют моки (MockCoreDataService, MockNetworkService, MockUserDefaultsService)
- Асинхронные операции тестируются с помощью XCTestExpectation
- Core Data операции выполняются в in-memory контейнере для изоляции тестов
- Тесты покрывают как успешные сценарии, так и обработку ошибок
- Соблюдается принцип Given-When-Then для структурирования тестов

## АРХИТЕКТУРНЫЕ ПРИНЦИПЫ:

- Тесты не зависят от UI компонентов
- Каждый тест проверяет только один аспект функциональности
- Моки точно имитируют поведение реальных сервисов
- Тесты изолированы и не влияют друг на друга 
