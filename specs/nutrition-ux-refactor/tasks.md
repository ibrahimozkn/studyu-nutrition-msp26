---
spec: nutrition-ux-refactor
phase: tasks
total_tasks: 24
created: 2025-01-22
generated: auto
---

# Tasks: Nutrition Logging UX Refactor

## Phase 1: Make It Work (POC)

Focus: Validate the consolidated meal entry screen works end-to-end. Skip advanced features, accept hardcoded values where needed.

- [x] 1.1 Create LLM integration interface and mock parser
  - **Do**: Create `app/lib/services/llm/meal_description_parser.dart` with abstract class defining `parseMealDescription()` and `parseFoodDescription()` methods. Create mock implementation returning sample FoodEntry objects.
  - **Files**:
    - `app/lib/services/llm/meal_description_parser.dart` (new)
    - `app/lib/services/llm/mock_meal_description_parser.dart` (new)
  - **Done when**: Mock parser compiles and returns 2-3 sample FoodEntry objects from a test string
  - **Verify**: Run `flutter analyze` - no errors
  - **Commit**: `feat(nutrition): add LLM parser interface and mock implementation`
  - _Requirements: FR-2, FR-8, US-2_
  - _Design: LLMIntegrationAdapter_

- [x] 1.2 Create NaturalLanguageInputWidget
  - **Do**: Create widget with TextField that accepts free text input. Store input in a callback. Add placeholder text "e.g., Oatmeal with berries and coffee". Do not integrate LLM yet - just store the text.
  - **Files**:
    - `app/lib/widgets/natural_language_input_widget.dart` (new)
  - **Done when**: Widget displays, accepts input, and calls callback on submit
  - **Verify**: Widget test showing input is captured
  - **Commit**: `feat(nutrition): add natural language input widget`
  - _Requirements: FR-2, AC-2.1, AC-2.2, AC-2.4_
  - _Design: NaturalLanguageInputWidget_

- [x] 1.3 Create FoodEntryChip widget
  - **Do**: Create widget that displays a FoodEntry as a chip with name, amount, unit, and calories. Add tap handler that opens a placeholder PortionAdjustmentSheet. Add swipe-to-delete or long-press delete gesture.
  - **Files**:
    - `app/lib/widgets/food_entry_chip.dart` (new)
    - `app/lib/widgets/portion_adjustment_sheet.dart` (new - placeholder for now)
  - **Done when**: Chip displays food info correctly and responds to tap/long-press
  - **Verify**: Widget test showing chip renders with sample FoodEntry
  - **Commit**: `feat(nutrition): add food entry chip widget with portion sheet`
  - _Requirements: FR-1, FR-6_
  - _Design: FoodEntryChip, PortionAdjustmentSheet_

- [x] 1.4 Implement PortionAdjustmentSheet with slider
  - **Do**: Create bottom sheet with Slider (0.5x to 3x range) and preset buttons (0.5x, 1x, 1.5x, 2x). Accept FoodEntry and callback for updated amount. Update display dynamically as slider moves.
  - **Files**:
    - `app/lib/widgets/portion_adjustment_sheet.dart` (complete implementation)
  - **Done when**: Sheet opens, slider adjusts amount, callback returns updated FoodEntry
  - **Verify**: Manual test - slider moves, values update correctly
  - **Commit**: `feat(nutrition): implement portion adjustment slider`
  - _Requirements: FR-6, AC-3.3_
  - _Design: PortionAdjustmentSheet_

- [x] 1.5 Create TemplateCarouselWidget
  - **Do**: Create horizontal scrolling list of template cards using TemplateViewModel. Each card shows template name, food count, and quick-add button. Use existing GatsotSelector pattern for scrolling.
  - **Files**:
    - `app/lib/widgets/template_carousel_widget.dart` (new)
  - **Done when**: Carousel displays up to 3 templates horizontally, tapping + adds foods to list
  - **Verify**: Widget test showing carousel renders
  - **Commit**: `feat(nutrition): add template carousel widget`
  - _Requirements: FR-4, AC-4.2, AC-4.4_
  - _Design: TemplateCarouselWidget_

- [x] 1.6 Create InlineFoodSearchSheet
  - **Do**: Extract search logic from existing FoodSearchScreen into reusable bottom sheet. Use DraggableScrollableSheet at 50% height. Maintain parallel search (USDA, OpenFoodFacts, templates).
  - **Files**:
    - `app/lib/screens/study/nutrition/inline_food_search_sheet.dart` (new)
    - `app/lib/screens/study/nutrition/food_search_screen.dart` (refactor - extract shared logic)
  - **Done when**: Sheet opens, searches parallel databases, returns FoodEntry on selection
  - **Verify**: Manual test - search "apple" returns results
  - **Commit**: `feat(nutrition): add inline food search bottom sheet`
  - _Requirements: FR-5, AC-3.1_
  - _Design: InlineSearchBottomSheet_

- [x] 1.7 Create QuickFoodAddWidget
  - **Do**: Create widget showing "Recent Foods" chips (hardcoded 3-4 items for POC) and action buttons: "Search" (opens InlineFoodSearchSheet), "Scan Barcode" (existing), "Custom Food" (existing FoodEntryScreen).
  - **Files**:
    - `app/lib/widgets/quick_food_add_widget.dart` (new)
  - **Done when**: Widget displays recent foods and buttons, tapping search opens sheet
  - **Verify**: Widget test showing all elements render
  - **Commit**: `feat(nutrition): add quick food add widget`
  - _Requirements: FR-3, FR-5_
  - _Design: QuickFoodAddWidget_

- [x] 1.8 Create QuickMealEntryScreen scaffold
  - **Do**: Create main screen widget with: meal type selector (auto-suggested based on time), time picker, NaturalLanguageInputWidget, TemplateCarouselWidget, FoodEntryChip list, QuickFoodAddWidget. Use Provider for state. Wire up to existing DailyRecallEntryViewModel.
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_screen.dart` (new)
  - **Done when**: Screen renders all widgets, meal type auto-suggests correctly
  - **Verify**: `flutter test` - screen builds without errors
  - **Commit**: `feat(nutrition): add quick meal entry screen scaffold`
  - _Requirements: FR-1, FR-4, FR-7, AC-1.2_
  - _Design: QuickMealEntryScreen_

- [x] 1.9 Wire up food addition flow
  - **Do**: Connect InlineFoodSearchSheet result to QuickMealEntryScreen state. Update FoodEntryChip list when food is added. Implement add/remove/update methods in screen state.
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_screen.dart` (modify)
  - **Done when**: Adding food from search updates the displayed list
  - **Verify**: Manual test - search food, add it, see it in list
  - **Commit**: `feat(nutrition): wire up food addition flow`
  - _Requirements: FR-1, AC-1.1_

- [x] 1.10 Wire up template application
  - **Do**: Connect TemplateCarouselWidget quick-add to QuickMealEntryScreen. Applying template should add all foods from template to the food list using TemplateViewModel.applyMealTemplate().
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_screen.dart` (modify)
  - **Done when**: Tapping template + adds all foods to list
  - **Verify**: Manual test - apply template, see all foods appear
  - **Commit**: `feat(nutrition): wire up template application`
  - _Requirements: FR-4, AC-4.1, AC-4.4_

- [x] 1.11 Wire up portion adjustment
  - **Do**: Connect FoodEntryChip tap to PortionAdjustmentSheet with current FoodEntry. Update the food in the list when portion is changed.
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_screen.dart` (modify)
  - **Done when**: Tapping food chip opens slider, adjusting updates the chip
  - **Verify**: Manual test - adjust portion, see calories update
  - **Commit**: `feat(nutrition): wire up portion adjustment`
  - _Requirements: FR-6_

- [x] 1.12 Wire up save to existing MealLog/DailyRecall
  - **Do**: Connect save button to create MealLog from screen state and return to NutritionTaskWidget. Ensure proper integration with existing DailyRecallEntryViewModel.addMeal().
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_screen.dart` (modify)
    - `app/lib/screens/study/tasks/observation/nutrition_task_widget.dart` (modify - add route to QuickMealEntryScreen)
  - **Done when**: Saving meal returns to NutritionTaskWidget and meal appears in list
  - **Verify**: Manual test - log meal, see it in daily recall
  - **Commit**: `feat(nutrition): wire up save to daily recall`
  - _Requirements: FR-10_

- [x] 1.13 POC Checkpoint
  - **Do**: Verify end-to-end flow works: open screen -> apply template OR add food -> adjust portion -> save. Test with at least 2 foods.
  - **Done when**: Complete meal can be logged in under 10 taps
  - **Verify**: Manual test of full flow, count taps
  - **Commit**: `feat(nutrition): complete POC - quick meal logging functional`
  - _Requirements: US-1, AC-1.1_

## Phase 2: Refactoring

After POC validated, clean up code and prepare for production.

- [ ] 2.1 Extract QuickMealEntryViewModel
  - **Do**: Extract state management logic from QuickMealEntryScreen into separate ChangeNotifier class. Follow pattern of TemplateViewModel.
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_view_model.dart` (new)
    - `app/lib/screens/study/nutrition/quick_meal_entry_screen.dart` (refactor)
  - **Done when**: All business logic in ViewModel, screen only renders
  - **Verify**: `flutter analyze` - no issues
  - **Commit**: `refactor(nutrition): extract QuickMealEntryViewModel`
  - _Design: State Management_

- [ ] 2.2 Add recent foods tracking
  - **Do**: Create RecentFoodsStorage class to persist recently used foods locally. Update QuickFoodAddWidget to load from storage instead of hardcoded values.
  - **Files**:
    - `app/lib/util/recent_foods_storage.dart` (new)
    - `app/lib/widgets/quick_food_add_widget.dart` (modify)
  - **Done when**: Recent foods persist across app sessions
  - **Verify**: Add food, close app, reopen - food still in recent
  - **Commit**: `feat(nutrition): add recent foods persistence`
  - _Requirements: FR-12, AC-3.2_

- [ ] 2.3 Add advanced options expansion
  - **Do**: Add GatsotExpansionTile for advanced meal fields (mealContext, companyContext, distractionContext, locationDescription). Use existing pattern from meal_entry_screen.dart.
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_screen.dart` (modify)
  - **Done when**: Advanced fields collapsible, default collapsed state
  - **Verify**: Advanced options hidden by default, expandable
  - **Commit**: `feat(nutrition): add advanced options expansion`
  - _Requirements: FR-9, AC-5.1, AC-5.3_

- [ ] 2.4 Implement smart defaults
  - **Do**: Auto-set meal type based on time (existing _getMealTypeByTime logic). Set default mealContext to home. Set default timestamp to now.
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_view_model.dart` (modify)
  - **Done when**: Screen opens with appropriate meal type pre-selected
  - **Verify**: Open at 8am -> Breakfast, 1pm -> Lunch
  - **Commit**: `feat(nutrition): implement smart defaults`
  - _Requirements: FR-7, AC-1.2, AC-5.4_

- [ ] 2.5 Add LLM input placeholder integration
  - **Do**: When user submits natural language input, show a "Processing..." state. For now, return mock results from MockMealDescriptionParser. Store the input text for future processing.
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_view_model.dart` (modify)
    - `app/lib/services/llm/mock_meal_description_parser.dart` (enhance)
  - **Done when**: Submitting text returns mock FoodEntry objects added to list
  - **Verify**: Type "oatmeal", submit, see mock foods appear
  - **Commit**: `feat(nutrition): add LLM input mock processing`
  - _Requirements: FR-2, FR-8, AC-2.3, AC-2.5_

- [ ] 2.6 Add error handling and loading states
  - **Do**: Add try/catch for all async operations. Show loading indicators during search and template loading. Show error messages with retry options.
  - **Files**:
    - `app/lib/screens/study/nutrition/quick_meal_entry_view_model.dart` (modify)
    - `app/lib/screens/study/nutrition/quick_meal_entry_screen.dart` (modify)
    - `app/lib/screens/study/nutrition/inline_food_search_sheet.dart` (modify)
  - **Done when**: All async operations have loading and error states
  - **Verify**: Test with airplane mode - see error message
  - **Commit**: `refactor(nutrition): add error handling and loading states`
  - _Design: Error Handling_

- [ ] 2.7 Add localization strings
  - **Do**: Add all new strings to app_localizations.dart and translations (en, de). Use AppLocalizations everywhere.
  - **Files**:
    - `app/l10n/app_localizations.dart` (modify)
    - `app/l10n/app_localizations_en.dart` (modify)
    - `app/l10n/app_localizations_de.dart` (modify)
  - **Done when**: No hardcoded strings, all localized
  - **Verify**: `flutter analyze` - no l10n warnings
  - **Commit**: `feat(nutrition): add localization for new features`
  - _Requirements: NFR-4_

## Phase 3: Testing

- [ ] 3.1 Widget tests for NaturalLanguageInputWidget
  - **Do**: Create test file verifying input capture, callback invocation, placeholder text.
  - **Files**:
    - `app/test/widgets/natural_language_input_widget_test.dart` (new)
  - **Done when**: Test coverage > 80% for widget
  - **Verify**: `melos run test` passes
  - **Commit**: `test(nutrition): add NaturalLanguageInputWidget tests`
  - _Requirements: AC-2.1, AC-2.2_

- [ ] 3.2 Widget tests for FoodEntryChip
  - **Do**: Create test file verifying chip rendering, tap callback, delete gesture.
  - **Files**:
    - `app/test/widgets/food_entry_chip_test.dart` (new)
  - **Done when**: Test coverage > 80% for widget
  - **Verify**: `melos run test` passes
  - **Commit**: `test(nutrition): add FoodEntryChip tests`
  - _Requirements: FR-6_

- [ ] 3.3 Widget tests for TemplateCarouselWidget
  - **Do**: Create test file verifying carousel rendering, template display, tap callback.
  - **Files**:
    - `app/test/widgets/template_carousel_widget_test.dart` (new)
  - **Done when**: Test coverage > 80% for widget
  - **Verify**: `melos run test` passes
  - **Commit**: `test(nutrition): add TemplateCarouselWidget tests`
  - _Requirements: FR-4_

- [ ] 3.4 Integration test for quick meal flow
  - **Do**: Create integration test simulating user opening screen, selecting template, adding food, adjusting portion, saving.
  - **Files**:
    - `app/integration_test/quick_meal_flow_test.dart` (new)
  - **Done when**: Full flow automated and passes
  - **Verify**: `melos run test` passes, flow completes in < 10 taps
  - **Commit**: `test(nutrition): add quick meal integration test`
  - _Requirements: US-1, AC-1.1_

- [ ] 3.5 Mock LLM parser tests
  - **Do**: Create tests verifying MockMealDescriptionParser returns valid FoodEntry objects with proper structure.
  - **Files**:
    - `app/test/services/llm/mock_meal_description_parser_test.dart` (new)
  - **Done when**: Parser interface contract validated
  - **Verify**: `melos run test` passes
  - **Commit**: `test(nutrition): add mock LLM parser tests`
  - _Requirements: US-2, FR-8_

## Phase 4: Quality Gates

- [ ] 4.1 Local quality check
  - **Do**: Run `melos format`, `melos run generate`, `flutter analyze`. Fix all issues.
  - **Verify**: No lint errors, no analyze errors, code formatted
  - **Done when**: All quality commands pass
  - **Commit**: `fix(nutrition): address lint and type issues` (if needed)
  - _Requirements: NFR-1, NFR-2, NFR-3_

- [ ] 4.2 Web responsiveness check
  - **Do**: Run `melos run app` and verify QuickMealEntryScreen displays correctly on web (Chrome). Check bottom sheet behavior, carousel scrolling.
  - **Verify**: No layout issues on web viewport
  - **Done when**: Web experience matches mobile expectations
  - **Commit**: `fix(nutrition): address web responsiveness issues` (if needed)
  - _Requirements: NFR-5_

- [ ] 4.3 Create PR and verify CI
  - **Do**: Push branch, create PR with gh CLI. Watch CI checks.
  - **Verify**: `gh pr checks --watch` all green
  - **Done when**: PR ready for review
  - **Commit**: (PR created via gh CLI)
  - _Requirements: All NFRs_

## Notes

- **POC shortcuts taken**:
  - Recent foods hardcoded initially
  - LLM parser is mock only
  - Limited error handling in POC phase
  - No animation polish

- **Production TODOs**:
  - Replace mock LLM with real service
  - Add analytics for tap counting
  - Consider adding haptic feedback
  - Add undo/redo for food list modifications
  - Consider voice input for natural language
  - A/B test against original flow

- **Dependencies preserved**:
  - All core models unchanged (DailyRecall, MealLog, FoodEntry, Templates)
  - Existing Provider pattern maintained
  - All existing screens kept (not deleted)
  - TemplateStorageManager reused

- **Migration path**:
  - Phase 1: QuickMealEntryScreen accessible via new button
  - Phase 2: Make QuickMealEntryScreen default, old flow as "Advanced" option
  - Phase 3: Remove old flow after validation period
