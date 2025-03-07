def zig_proto_gen(name, proto_files):
    """Rule that invokes Zig's protobuf generator.
    
    Args:
        name: A unique name for this rule.
        proto_files: List of proto files to be processed by the generator.
    """
    # Generate output paths for the proto files
    outs = []
    for proto in proto_files:
        # Extract the base proto name without path and extension
        proto_name = proto.split("/")[-1].replace(".proto", "")
        outs.append("src/proto/{}.zig".format(proto_name))
    
    native.genrule(
        name = name,
        srcs = proto_files,
        outs = outs,
        cmd = """
            # Get the absolute paths of the proto files
            PROTO_FILES="$(SRCS)"
            
            # Create destination directory if it doesn't exist
            mkdir -p src/proto
            
            # Run the Zig build command with the proto files as arguments
            zig build gen-proto -- $${PROTO_FILES}
        """,
    )