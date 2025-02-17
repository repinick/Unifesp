import React from 'react';
import InputMask from "react-input-mask";

interface InputProps {
    id: string;
    label: string;
    type: string;
    required: boolean;
    register?: any;
    mask?: string;
}

const inputClasses = 'w-52 h-10 text-center text-gray-700 rounded-lg border border-gray-300 py-1 px-4 focus:outline-none focus:border-green-500';
const dateInputClasses = 'rounded-lg border border-gray-300 py-1 px-9 focus:outline-none focus:border-green-500';

export default function Input(props: InputProps) {
    return (
        <div>
            <div className='flex flex-col justify-center items-center'>
                <label htmlFor={props.id} className='text-white'>
                    {props.label}
                </label>
                <div className='mb-4 mt-0.5'>
                    {props.mask == 'CPF' ? (
                        <InputMask
                            className={inputClasses}
                            mask={"999.999.999-99"}
                            {...props.register(props.id, { required: true })}
                        />
                    ) : ( props.mask == 'RG' ? (
                        <InputMask
                            className={inputClasses}
                            mask={"99.999.999-9"}
                            {...props.register(props.id, { required: true })}
                        />
                    ) : (
                        <input
                            {...props.register(props.id, { required: props.required })}
                            id={props.id}
                            type={props.type}
                            className={(props.type == 'date' ? dateInputClasses : inputClasses)}
                        />
                    ))}
                </div>
            </div>
        </div>
    )
}