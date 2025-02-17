import React from "react";

interface IconTextProps {
    icon: string;
    text: string;
}
  
export default function IconText(props: IconTextProps) {
    return (
        <div className='flex flex-col items-center'>
          <img src={props.icon} alt="Icon" className='w-24 h-24 mx-24' />
          <span className='mt-2 whitespace-pre-wrap text-center'>
            {props.text.split('<br />').map((line, index) => (
            <React.Fragment key={index}>
              {line}
              <br />
            </React.Fragment>
        ))}
      </span>
        </div>
      );
}