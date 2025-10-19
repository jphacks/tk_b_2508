# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MIERUTE is a SwiftUI iOS application following a strict MVVM & Clean Architecture with component-based UI design.

### Product Concept

企業が製品の説明をWeb上でノードでつながったブロックの手順書を作成し、それをQRコード化します。iOS側でQRコードを読み込んで情報を取得し、カメラ上にテキストを表示して説明内容を見ることができるARアプリケーションです。

**主な機能:**
- QRコードスキャン機能
- Web APIからの手順書データ取得
- ARカメラ上でのテキスト表示
- ノードベースの手順書ナビゲーション

## API Endpoints

**Base URL:** `https://us-central1-mierute-c7b7f.cloudfunctions.net/api`

### App Controller (Root Level)
- `GET /` - Hello world endpoint
- `GET /items` - Get all items (pagination: limit, orderBy)
- `POST /items` - Create new item
- `GET /items/:id` - Get item by ID
- `PUT /items/:id` - Update item by ID
- `DELETE /items/:id` - Delete item by ID
- `POST /items/batch` - Batch operations

### Project Controller
- `GET /api/projects` - Get all projects
- `POST /api/projects` - Create new project
- `GET /api/projects/:id` - Get project by ID
- `PUT /api/projects/:id` - Update project by ID
- `DELETE /api/projects/:id` - Delete project by ID

### Block Controller
- `GET /api/blocks` - Get all blocks
- `POST /api/blocks` - Create new block
- `GET /api/blocks/:id` - Get block by ID
- `GET /api/blocks/project/:projectId` - Get blocks by project ID
- `PUT /api/blocks/:id` - Update block by ID
- `DELETE /api/blocks/:id` - Delete block by ID

### Image Recognition Controller
- `POST /api/image-recognition` - Analyze image for checkpoint (multipart/form-data: image file + block_id)

## Build Commands

```bash
# Build the project
xcodebuild -project MIERUTE.xcodeproj -scheme MIERUTE -configuration Debug build

# Run tests
xcodebuild test -project MIERUTE.xcodeproj -scheme MIERUTE -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build
xcodebuild clean -project MIERUTE.xcodeproj -scheme MIERUTE
```

## Architecture

### Core Principles

**MVVM & Clean Architecture:**
- Always implement features using MVVM (Model-View-ViewModel) pattern
- Follow Clean Architecture principles: separation of concerns, dependency inversion
- View → ViewModel → Use Cases/Services → Data Layer
- Business logic resides in ViewModels and Services, never in Views
- Models represent data structures and domain entities

**File Organization:**
- One class, struct, or protocol per file
- Extensions can be in the same file as the type they extend
- Feature-based directory structure (organize by screen/feature, not by type)
- Group related components within their feature directories

### Directory Structure Convention

Organize code by feature/screen, not by type:

```
MIERUTE/
├── {FeatureName}ViewGroup/
│   ├── {FeatureName}View.swift
│   ├── {FeatureName}ViewModel.swift
│   └── Components/
│       ├── {ComponentName}.swift
│       └── ...
├── Models/
│   ├── {ModelName}/
│   │   └── {ModelName}.swift
├── Services/
│   └── {ServiceName}.swift
└── Extensions/
    └── {TypeName}+Extension.swift
```

**Critical Rules:**
- One file per View/ViewModel/Model/Component
- ViewModels are initialized at call site: `MyView(viewModel: .init())`
- Never initialize ViewModel inside the View's body or init
- Services are `enum` (not classes), called via `MyService.method()`

### View Architecture

**Component Extraction:**
- Extract UI into separate Component structs, never use `private var` within View
- Each component gets its own file in a `Components/` subdirectory
- Components must be standalone structs conforming to `View`

**View Hierarchy:**
```swift
struct MyView: View {
    let viewModel: MyViewModel  // NOT @StateObject/@ObservedObject
    @Binding var someBinding: String
    @State private var localState: Bool
    var someParameter: Int

    var body: some View {
        // UI code
    }
}

// REQUIRED: Always add Preview
#Preview {
    MyView(
        viewModel: .init(),
        someBinding: .constant(""),
        someParameter: 42
    )
}

// Usage
MyView(
    viewModel: .init(),
    someBinding: $binding,
    someParameter: 42
)
```

**Layout Requirements:**
- All screens must use `.frame(maxWidth: .infinity, maxHeight: .infinity)`
- Prefer `overlay`/`background` over `ZStack`
- Ensure proper contrast: dark backgrounds = white text, light backgrounds = dark text

### ViewModel Pattern

```swift
import Combine

@MainActor
final class MyViewModel: ObservableObject {
    @Published var state: ViewState = .initial

    // Business logic here
    func performAction() {
        // Implementation
    }
}
```

**Rules:**
- All functions belong in ViewModel, never in View
- ViewModels can call Services, Extensions, and Models
- Keep View logic minimal—just rendering and user interaction

### Models

**Codable Compliance:**
- All Firebase/API models must conform to `Codable`
- Add `.encoded()` helper for clean encoding
- One model per file, grouped in subdirectories by category

```swift
// Models/User/User.swift
struct User: Codable, Identifiable {
    let id: String
    let name: String

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
```

### Services

Services are stateless utilities defined as `enum`:

```swift
// Services/FirestoreService.swift
enum FirestoreService {
    static func fetchUser(id: String) async throws -> User {
        // Implementation
    }
}

// Usage
let user = try await FirestoreService.fetchUser(id: userId)
```

**Never:**
- Make Services conform to `ObservableObject`
- Create Service instances
- Use UserDefaults (use SwiftData instead)

### Data Persistence

- Use SwiftData for local storage, NOT UserDefaults
- All database operations must go through Codable models
- Never manually construct JSON arrays

## Implementation Workflow

1. **UI First:** Implement and show UI for approval
2. **Then Functions:** After UI approval, implement business logic
3. **Full Integration:** Always update call sites when modifying function signatures
4. **Validation:** Run `xcodebuild` to verify no compilation errors

## Code Quality Standards

**File Structure:**
- One class, struct, or protocol per file (MANDATORY)
- Extensions can remain in the same file as the type they extend
- File name must match the type name (e.g., `User.swift` for `struct User`)

**View Requirements:**
- All Views MUST include `#Preview` for development and testing
- Variable declaration order: `viewModel` → `@Binding` → `@State` → `var/let`
- State management: minimize `@State`, prefer ViewModel properties

**General:**
- Import `Combine` whenever using `ObservableObject`
- Check official SwiftUI modifiers before implementing custom gestures
- Use DocumentID for identifiers, not UUID
- Follow MVVM & Clean Architecture principles consistently

## Reporting

After implementation, always report:
1. Which files were created/modified
2. What functionality was implemented
3. Current state of the UI/feature
4. Any build errors or warnings (run xcodebuild to check)
