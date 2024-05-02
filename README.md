# Tops

## About AniTop Project

This project is supported by the University of Michigan MATH 440 Lab of Geometry 2024WN team Tops.

### Background

In this project, we aim to create simulation for the movements of these three tops to visualize rotation, precession, and nutation to better understand planetary motion.

### Features

We present a simulation and animation framework for three kinds of integrable tops: Euler, Lagrange, and Kovalevskaya Tops. For theories behind our implementation, please refer to [Theory.md](Theory.md)

## Quick Starter Guide

- To quickly get started and see what this package does, please refer to [Get Started](#get-started).
- For more advanced uses and custom configurations, please refer to [Configurations](#configurations).
- Want to use components of this package to aid your research? Please refer to [File Structure](#file-structure) to learn about everything in this package!
- Want to develop and extend the AniTop capabilities? Refer to [For Developers](#for-developers) section for details. Welcome!

## Get Started

To try our project yourself, first clone this repository and enter project directory

```bash
cd <Whereever_You_Want_The_Project_to_Be>
git clone https://gitlab.eecs.umich.edu/logm/wi24/tops.git
cd tops
```

Then, choose your preferred language.

**WARNING:** due to different computing graphics libraries, simulations and animations produced by MATLAB and Python may not be identical. They will both be, however, close to each other and accurate approximate real-world scenarios.

### Get Started with MATLAB

- This packages requires **MATLAB R2023b** or later for styling graphic. Legacy versions of MATLAB are not accessible to the developers, thus we do not plan to support it. However, we welcome communty developers to contribute to legacy support!
- To run the MATLAB version, open `matlab/AniTop.m` in MATLAB and run `AniTop`.
- If MATLAB prompts you to change directory or add to path, you can choose either options. The package is designed to figure everything out by itself.

### Get Started with Python (Work in Progress)

- If you prefer running this package in a virtual environment like Anaconda, **activate your virtual environment first**. If you don't know what that is, you can ignore this message.
- The minumum version required for AniTop is **Python 3.7.x.** To check your python version, run
  ```bash
  >>> python3 --version
  Python 3.x.x
  ```

* To run the Python version of AniTop, enter the `py/` directory and install required packages:

  ```bash
  >>> cd py/
  >>> python3 -m pip install -r requirements.txt
  ```

  Then, run

  ```bash
  >>> python3 AniTop.py
  ```

## Configurations

Configuration of the simulator is done through `config/config.json`. We provided a config template that you can edit and make your own config file. For detailed instructions, options and references, please read `config/README.md`.

- Note that the source code does not ship with a `config.json` with specific reasons. Instead, we ship a `config.json.template` that is an example of valid configuration.
- If you run your program without creating a `config.json` beforehand, the program will do that for you by cloning `config.json.template` into a `config.json` file.

## File Structure

This project contains the following directories and files:

**From the Repository**

* `py/`
  * `sim/` directory includes a Python implementation of our simulators
  * `animation/` directory includes a Python implementation of our visualization framework.
  * `AniTop.py` is the driver program for the Python version of AniTop.
* `matlab/`
  * `sim/` directory includes a MATLAB implementation of our simulators
  * `animation/` directory includes a MATLAB implementation of our simulators
  * `AniTop.m` is the driver program for the MATLAB version of AniTop.
* `config/`
  * `config.json` contains the configuration options for the simulator to read. You can make changes to initial conditions that the simulators use to predict Tops motion. This file is NOT shipped with the repository. Instead, it will be created automatically upon first usage or by manual creation.
  * `config.json.template` contains a template for legal `config.json` for you. Please **do not modify** this so you can refer back to it for the correct formatting.
  * `config_checker.py` helps you check the validity of your cofig.json file, as debugging JSON is usually very tricky.
  * `README.md` contains information about everything configurable in this project.
* `files/` contains helper files and images used in this README and `Theory.md`.
* `Theory.md` documents the theories behind creating these simulators.
* `TopEuler/` contains files from [Animated Spinning Top with Cardan Mounting](https://www.mathworks.com/matlabcentral/fileexchange/28309) project by Alexander Erlich that inspired our project.

**Local Directories**

- `data/` stores all the simulation outputs. Data files in this directory is ignored by Git.
- `animations/` stores all the animation videos produced by the animator.

These directories are not shipped with the repository. Instead, they are automatically created by the program upon first usage.

You should always backup files in these folders somewhere secure, since Git does not sync any data or video files.

## For Open-Source Contributors

Please fork this repository and create pull requests when your contributions have been implemented. We greatly appreciate your enthusiasm and efforts for making this package better!

## Support

Please create an Issue for any support related question on this project. Questions will be added to a FAQ issue if it becomes common.

## Authors and acknowledgment

**Authors:** Haley Gipson, Ramon Diego Guerra, [Huaidian Daniel Hou](https://www.danielhou.me/), Anna Zitian Huang.

We greatly appreciate [Dr. Alejandro Bravo-Doddoli](https://public.websites.umich.edu/~abravodo/) and [Kausik Das](https://lsa.umich.edu/math/people/phd-students/kausik.html) for their mentoring of the project. We also thank the University of Michigan MATH 440: Lab of Geometry program and [Dr. Nir Gadish](https://websites.umich.edu/~gadish/) for making this experience possible.

## License

This project is published under the LGPL license. For details, see [LICENSE](LICENSE).

## Project status

This project is developed by the University of Michigan LoG(M) Tops Team during the Winter 2024 semester. The project is still under active maintenance (bug fixes, etc), but feature development will be slow, if any.
