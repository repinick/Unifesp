interface ButtonProps {
    className: string
    type: "button" | "submit" | "reset" | undefined
    children: any
    onClick?: () => void;
}

export default function Button(props: ButtonProps) {
    const handleClick = () => {
        if (props.onClick) {
          props.onClick();
        }
    };
    
    return (
        <button 
            type={props.type}
            className={`
                ${props.className}
            `}
            onClick={handleClick} 
        >
            {props.children}
        </button>
    )
}
