# Godot-IDP

Godot-IDP is a plugin that integrates the symbolic AI engine IDP-Z3 into the Godot game engine. It allows game developers to leverage the power of IDP-Z3 for creating complex AI behaviors, generating procedural content, and handling various logical constraints within their games.

## Installation

1. **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/Godot-IDP.git
    ```

2. **Copy the plugin into your Godot project:**
    - Copy the `Godot-IDP` folder into the `res://addons/` directory of your Godot project.

3. **Enable the plugin in Godot:**
    - Open your project in Godot.
    - Go to `Project` -> `Project Settings` -> `Plugins`.
    - Find `Godot-IDP` in the list and enable it.

4. **Setup Python environment:**
    - Navigate to your Godot project folder and create a virtual environment named `venv`:
    ```bash
    python -m venv venv
    ```
    - Activate the virtual environment:
        - On Windows:
        ```bash
        venv\Scripts\activate
        ```
        - On macOS/Linux:
        ```bash
        source venv/bin/activate
        ```
    - Install the required Python packages by running:
    ```bash
    pip install -r requirements.txt
    ```

## Usage

Here is an example script to demonstrate how to use Godot-IDP:

```gdscript
extends Node

func _ready() -> void:
    # Create an empty knowledge base
    var kb = IDP.create_empty_kb()
    
    # Add a type T with a range of integer values
    var T = kb.add_type("T", range(0, 6), IDP.INT)
    
    # Add a function 'func1' returning BOOL and taking T as a parameter
    var func1 = kb.add_function("func1", IDP.BOOL, T)
    
    # Add a predicate 'pred1' with BOOL and T as parameters, and initialize with values
    var pred1 = kb.add_predicate("pred1", [IDP.BOOL, "T"], [[true, 3], [false, 4]])
    
    # Add a constant 'const1' of type REAL
    var const1 = kb.add_constant("const1", IDP.REAL)
    
    # Set values to the function, predicate, and constant
    func1.add(true, 0)
    pred1.remove([false, 4])
    const1.set_value(4.6)
    
    # Print the knowledge base in IDP format
    print(kb.parse_to_idp())
    
    # Create a new empty knowledge base
    kb = IDP.create_empty_kb()
    T = kb.add_type("T", range(0, 6), IDP.INT)
    pred1 = kb.add_predicate("pred1", ["T"])
    
    # Add terms and formulas to the knowledge base
    var add_term = Real.base_(3).add(2)
    var lte_term = add_term.lte("x")
    var implies_term = IDP.p_not(pred1.apply([2]).implies(lte_term))
    
    kb.add_formula(add_term)
    kb.add_formula(lte_term)
    kb.add_formula(implies_term)
    
    # Perform model expansion
    IDP.model_expand(kb)
    
    # Print the knowledge base in IDP format
    print(kb.parse_to_idp())

    # Print the list of model expand solutions
    print(kb.solutions)
```
