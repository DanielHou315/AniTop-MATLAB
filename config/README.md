# Tops Config

This README documents how to configure a Tops configuration. A template is provided for you as `config.json.template`. You should create your own `config.json` file that is by default imported by the Tops program, both MATLAB and Python variants.

The configuration is in the form of JSON document. New to JSON? You can read [this short crash course](https://dev.to/talibackend/json-crash-course-4pof) to learn more.

## Get Started

To start, duplicate `config.json.template` as `config.json` in the same `config/` directory.

```bash
cd <Project_Directory>/config
cp ./config.json.template ./config.json
```

Now you can edit config.json to whatever you prefer to configure the simulator and animator! All available options are available in this document.

Note that Git does not track this file because the configuration may be different for everyone. You should regularly backup your `config.json` file somewhere secure.

### Checking Configuration Validity

Before you start, `config_checker.py` is your friend. While understanding this document is important, it is very common to misstype something. While our main functions do not check for as many errors (they just crash when something is badly configured), we provide a pure Python script `config_checker.py` that checks for the vast majority of illegal configurations possible. To run this script, simply run

```json
python3 config_checker.py
```

or, if you use a configuration file that is named other than `config.json`, you can optionally set the `-f` flag and specify a config file.

```json
python3 config_checker.py -f path/to/your/config.json
```

## Example

An example configuration is as follows.

```json
{
  "mode":"single", 
  "verbose":false,
  "sim":{
    "tops":[
      "euler",
      "lagrange",
      "kovalevskaya"
    ],
    "init_ang_momentum":[
      [1,2,3], 
      [2,2,5]
    ],
    "init_ang_velocity":[
      [0.9,0,0.145],
      [0.8,0.2,0]
    ],
    "init_heading":[
      [180,0,180],
      [90,90,0]
    ]
  },
  "animation":{
    "kernel":"Tops",
    "show_energy":"sliding",
    "show_energy_scale":1,
    "show_momentum": "none",
    "show_em_contour": "fixed",
    "show_euler_angles":"sliding",
    "show_euler_rates":"fixed"
  }
}
```

## Options Breakdown

The configuration includes a few level-1 parameters that are required for the entire program.

Note that any other configurations will be ignored by the program. They will not crash. You can take advantage of this and add some comments inside your configuration.

### Mode

The "mode" option configures how the program treats the initial conditions. Through "mode", more than one animation can be created by specific rules without the need to create more than one config files.

**Required:** True

**Default Value:** Nopne

**Legal options**:

- "single": this mode renders a **single** animation from the configuration. For each of the initial conditions options in `sim`, the **first entry** is taken, and all the **remaining options are ignored**.
- "one-to-one": in this mode, the simulator takes the `i-th` entry of each sim configuration and creates an animation for that specific combination of initial conditions. Note that this mode **requires** that tops, initial angular momentum, initial angular velocity, and initial heading have **the same number of entries**.
  - For example, if each of the sim configurations have 2 entries, then the program will create 2 simulations and animations, each with configuration entry (1) from each option and entry (2) from each option.
- "grid": in this mode, the simulator (and animator, for that matter) will create a unique simulation and animation for **each combination** of initial conditions, including the type of top, initial angular momentum, initial angular velocities, and initial heading.
  - For example, if each of the sim configurations have 2 entries, then the program will create
  - If there are duplicate entries, the program will NOT attempt to remove duplicates. It is your responsibility to make sure that your config does not have duplicates.

### Verbose

This is a flag for developers (If you are one, hello~). This flag turns on many debugging outputs in the implementation to allow you to understand how our simulator things the world works. If you contribute to our project, feel free to add code that supports this flag.

**Required:** True

**Legal Options:**

- `true ` or `false`, it must be one of two Boolean values.

### Sim

#### tops

This is a list of tops to animate. Depending on `Mode`, some of the tops may be ignored or used more than once.

**Required:** True

**Default Value:** None, user must set this option.

**Legal options:**

- "euler": representing an Euler Top.
- "lagrange": representing a Lagrange Top.
- "kovalevskaya": representing a Kovalevskaya Top.

#### init_moment_inertia

This is a list of (3x1) arrays that represent the initial moment of inertia of the target top. Default order of these three numbers is recorded in `Theory.md`.

**Required:** True

**Default Value:** None, user must set this option.

**Legal options:**

- N x (3x1) arrays with integers or floating positive numbers.

#### init_ang_velocity

This is a list of (3x1) arrays that represent the initial Angular Velocities of the target top. Default order of these three numbers is recorded in `Theory.md`.

**Required:** True

**Default Value:** None, user must set this option.

**Legal options:**

- N x (3x1) arrays with integers or floating positive numbers.

#### init_heading

This is a list of (3x1) arrays that represent the initial Euler Angles of the target top. Default headings, in degrees, of each type of top is recorded in `Theory.md`. Degrees are used rather than radians because of the simplicity of representing and understanding degree numbers with JSON. Storing a fraction of $\pi$ and parsing it in the program is much more difficult.

**Required:** True

**Default Value:** None, user must set this option.

**Legal options:**

- N x (3x1) arrays with integers or floating numbers, each in the range [-180, 180].

#### mgl

This is a list of scalars that represent initial Lagrange Top $\text{mass} \times g \times \text{length}$, where $g=9.8m \cdot s^{-2}$

**Required:** True

**Default Value:** None, user must set this option.

**Legal options:**

- N-length arrays with positive integers or floating numbers

#### mga

This is a list of scalars that represent initial Kovalevskaya Top $\text{mass} \times g \times \text{CoMoffset}$, where $g=9.8m \cdot s^{-2}$

**Required:** True

**Default Value:** None, user must set this option.

**Legal options:**

- N-length arrays with positive integers or floating numbers

### Animation

#### kernel

The "kernel" option allows you to set the graphics framework to render the animation. We provide our own animation framework in the `matlab/animation` and `py/animation` packages, respectively. However, we greatly appreciate the inspiration of the TopEuler project by Alexander Erlich, published on MATLAB File Exchange, we included their work as a separate animation framework. You can checkout their source code on MATLAB File Exchange.

**Required:** True

**Legal options:**

- """TopEuler": this option uses the TopEuler package to render simulation results.
  - WARNING: TopEuler rendering is NOT available if you are running the Python version.
- "Tops": this option uses the visualization framework we provide, which contains many interesting and amazing features.
- "none": this option skips animation altogether. This is ideal if your graphics framework does not work with our

#### sliding_window

This option sets whether the animator displays 2D graphs with a sliding window or not.

NOTE: this is NOT available if you choose the "TopEuler" animation framework.

**Required:** True if `kernel="Tops"`

**Legal options:**

- true: the animator plots the system energy over time in a Sliding Window fashion with 5 second windows by default.
- false: the animator plots the system energy over time in a fixed window, where the x-axis ranges from 0 to $T$ throughout the video, where $T$ is the total time of the animation.
