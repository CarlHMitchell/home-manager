# Lessons & Things I've Learned

Each flake-parts module can create an input in the main flake.nix. E.g. the IosevkaCarl one. Update the main flake.nix contents with `nix run .#write-flake`. Update the flake.lock with `nix flake update .`. Update the system with `sudo nixos-rebuild switch --flake .#carl-nixos`

Each flake-parts module creates an output. 

Vibe-coded this. It sort of works, but I don't feel I have a good understanding of how it all actually fits together & how to properly extend it. Fine as a starting point, but learning Nix more deeply is also a goal. Treating this repo as a living example to compare to other examples, to see where my config might be improved.

> When defining a feature, we frequently want to reuse it within our hierarchical feature structure. To accomplish this, we define reusable modules by using the Flake Parts flake.modules attribute to store our feature building blocks.

> Creating such a reusable feature building block and storing it in flake.modules looks like this:

    flake.modules.<module class>.<aspect name> =
    {
    	imports = [ <list of other 'flake.modules' of same class> ];
    
        #
        # module code defining this `aspect`
        #
    }

> In most cases, the aspect name is the same as our feature name and can be used interchangeably. However, there are exceptions to this rule. When a feature contains multiple aspect definitions, I'll comment on that later.

> Every flake.modules definition has a configuration context, known as the <module class>, which serves as the code's reference point. The most commonly used module classes are nixos, darwin, and homeManager, and these are also demonstrated in the examples. Of course, the same principle applies if you use other class types, such as nixOnDroid or nixvim.

> flake.modules.<module class>.<aspect>s and features are structurally related in the following way:

> * One feature can define multiple aspects, especially for different module classes.
    aspects can be nested hierarchically using imports, which allows us to nest features. The use of module imports also changes how we enable something: instead of using enable = true;, we simply import the module. The code within the module enables the service, etc., by default.
> * A feature is sometimes more than a collection of aspect definitions: besides defining the structured module hierarchy, a feature sometimes defines or accesses other flake-parts attributes. Let's call these parts flake-parts boilerplate.
> * All features are imported by default. This means all aspects are defined and all flake-part boilerplates are active. However, be aware that an aspect definition is just that, a definition for our module library, so it remains inactive until it is used in some flake-parts boilerplate to be accessible at the flake outputs.

Flake-parts modules can't be imported into the wrong `class` of configurations. So trying to import a homeManager module into a nixos config will be a type error, not an undeclared option. The special attribute generic does not declare a class, allowing its modules to be used in any module class.
